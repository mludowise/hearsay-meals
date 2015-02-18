var util = require("cloud/util.js");

// Convenience classes
var BeerRequest = Parse.Object.extend("BeerRequest");
var Keg = Parse.Object.extend("Keg");

/* Returns the beer that's on tap
 *
 * Params: none
 *
 * Success: Returns JSON object of the most recent beer on tap or null if there isn't one.
 *	id (String): ID of the current keg
 *	beer (JSON): The beer on tap
 *		name (String): Name of the beer
 *	filled (Date): Date that the keg was filled
 *	kickedReports (JSON Array): A list of users who reported the keg was kicked.
 *		id (String) - id of the user
 * 		name (String) - name of the user
 * 		picture (String) - URL of the user's avatar
 *
 * Possible Errors:
 *	There is no keg.
 */
Parse.Cloud.define("beerOnTap", function(request, response) {
	var query = new Parse.Query(Keg);
	query.descending("createdAt");
	query.first().then(function(keg) {
		if (!keg) {
			response.error("There is no keg.");
			return null;
		}
		var result = {
			id: keg.id,
			beer: {
				name: keg.get("beerName")
			},
			filled: keg.createdAt
		};
		
		var kickedReports = keg.get("kickedReports");
		util.findUsers(kickedReports).then(function(users) {
			result.kickedReports = util.infoForUsers(users);
			response.success(result);
		}, function(users, error) {
			console.log(error);
			response.success(result);
		});
	},
	function(keg, error) {
		response.error(error);
	});
});

/* Marks that the current user reported the keg was kicked.
 *
 * Params:
 *	id (String): The id of the keg that is kicked.
 *
 * Success: Returns a JSON array of users who reported the keg was kicked.
 *		id (String) - id of the user
 * 		name (String) - name of the user
 * 		picture (String) - URL of the user's avatar
 *
 * Possible Errors:
 *	There is no user currently logged in.
 *	There is no keg.
 *	The current keg does not match the given id.
 */
Parse.Cloud.define("beerReportKicked", function(request, response) {
	if (!request.user) {
		response.error("No user is logged in.");
		return;
	}
	
	var query = new Parse.Query(Keg);
	query.descending("createdAt");
	query.first().then(function(keg) {
		if (!keg) {
			response.error("There is no keg.");
			return null;
		}
		if (keg.id != request.params.id) {
			response.error("The current keg does not match the id " + request.params.id + ".");
			return null;
		}
		
		keg.addUnique("kickedReports", request.user.id);
		keg.save(null, { useMasterKey: true }).then(function(keg) {
			var kickedReports = keg.get("kickedReports");
			util.findUsers(kickedReports).then(function(users) {
				response.success(util.infoForUsers(users));
			}, function(users, error) {
				response.error(error);
			});
		}, function(keg, error) {
			response.error("Could not update keg " + keg.id + ".");
		});
	}, function(keg, error) {
		response.error(error);
	});
});

/* Removes this user's report that the keg is kicked.
 *
 * Params: none
 *
 * Success: Returns a JSON array of users who reported the keg was kicked.
 *		id (String) - id of the user
 * 		name (String) - name of the user
 * 		picture (String) - URL of the user's avatar
 *
 * Possible Errors:
 *	There is no user currently logged in.
 *	There is no keg.
 *	The current keg does not match the given id.
 */
Parse.Cloud.define("beerUnreportKicked", function(request, response) {
	if (!request.user) {
		response.error("No user is logged in.");
		return;
	}
	
	var query = new Parse.Query(Keg);
	query.descending("createdAt");
	query.first().then(function(keg) {
		if (!keg) {
			response.error("There is no keg.");
			return null;
		}
		if (keg.id != request.params.id) {
			response.error("The current keg does not match the id " + request.params.id + ".");
			return null;
		}
		
		keg.remove("kickedReports", request.user.id);
		
		if (keg.get("kickedReports").length == 0) {
			keg.set("sent_kicked_notice", false);
		}
		
		keg.save(null, { useMasterKey: true }).then(function(keg) {
			var kickedReports = keg.get("kickedReports");
			util.findUsers(kickedReports).then(function(users) {
				response.success(util.infoForUsers(users));
			}, function(users, error) {
				response.error(error);
			});
		}, function(keg, error) {
			response.error("Could not update keg " + keg.id + ".");
		});
	}, function(keg, error) {
		response.error(error);
	});
});


var fillKeg = function(beerName, response) {
	var keg = new Keg();
	// TODO: User restricted ACL when adding Keg.
// 	keg.setACL(util.restrictedACL());
	keg.set("beerName", beerName)
	keg.set("kickedReports", []);
	keg.save().then(function(keg) {
		console.log("Keg updated to " + beerName + ".");
		response.success({
			name: beerName
		});
	},
	function(keg, error) {
		response.error(error);
	});
}

/* Marks the keg as filled with a specific beer.
 *
 * Params:
 *	name (String): Name of the beer
 *
 * Success:
 *	name: The name of the beer in the keg
 *
 * Possible Errors:
 *	No name is specified
 *	The current user does not have permission to fill the keg.
 */
Parse.Cloud.define("beerFillKeg", function(request, response) {
	var beerName = request.params.name;
	if (!beerName) {
		response.error("No beer was specified.");
		return;
	}
	if (!util.isUserAdmin(request.user)) {
		response.error("User does not have permission to update the keg.");
		return;
	}
	fillKeg(beerName, response);
});

/* Marks the keg as filled by a specific beer requested.
 * The beer request will be removed.
 *
 * Params:
 *	id (String): The id of the beer request 
 *
 * Success:
 *	name: The name of the beer in the keg
 *
 * Possible Errors:
 *	There is no user currently logged in.
 *	The current user does not have permission to fill the keg.
 *	There is no request with the specified id.
 */
Parse.Cloud.define("beerFillKegFromRequest", function(request, response) {
	var requestId = request.params.id;
	if (!requestId) {
		response.error("No beer request was specified.");
		return;
	}
	if (!request.user) {
		response.error("No user is logged in.");
		return;
	}
	if (!util.isUserAdmin(request.user)) {
		response.error("User does not have permission to update the keg.");
		return;
	}
	
	var query = new Parse.Query(BeerRequest);
	query.equalTo("objectId", requestId);
	query.first().then(function(beerRequest) {
		if (!beerRequest) {
			response.error("No request exits with the id " + requestId + ".");
		} else {
			beerRequest.destroy().then(function(beerRequest) {
				console.log("Successfully deleted beer request " + requestId + ".");
			},
			function(beerRequest, error) {
				console.error(error);
			});
			fillKeg(beerRequest.get("name"), response);
		}
	}, function(beerRequest, error) {
		response.error(error);
	});
});

/* Get beer requests.
 *
 * Params: none
 *
 * Success: List of JSON objects containing
 *	id (String): ID of the beer request
 *	name (String): Name of the beer
 *	votes (JSON Array): A list of users who reported the keg was kicked.
 *		id (String) - id of the user
 * 		name (String) - name of the user
 * 		picture (String) - URL of the user's avatar
 *
 * Possible Errors: none
 * 
 */
Parse.Cloud.define("beerGetRequests", function(request, response) {
	var query = new Parse.Query(BeerRequest);
	query.find().then(function(beerRequests) {
		// First get a combined list of all the users who voted
		var userIds = [];
		for (var r in beerRequests) {
			var beerRequest = beerRequests[r];
			var votes = beerRequest.get("votes");
			for (var u in votes) {
				userIds.push(votes[u])
			}
		}
		
		var userMap = {};
		util.findUsers(userIds).then(function(users) {
			// Find all the users who voted
			for (var u in users) {
				var user = users[u];
				userMap[user.id] = util.userInfo(user, false);
			}
			
			// Add them to the results
			var results = [];
			for (var r in beerRequests) {
				var beerRequest = beerRequests[r];
				var votes = beerRequest.get("votes");
				var usersVoted = [];
				for (var u in votes) {
					var userId = votes[u];
					var user = userMap[userId];
					if (user) {
						usersVoted.push(user);
					}
				}
				results.push({
					id: beerRequest.id,
					name: beerRequest.get("name"),
					votes: usersVoted
				});
			}
			
			// Sort results by descending number of votes
			results.sort(function(a, b) {
				return b.votes.length - a.votes.length;
			});
			
			response.success(results);
		}, function(users, error) {
			response.error(error);
		});
	}, function(beerRequests, error) {
		response.error(error);
	});
});

/* Request a beer and vote for it.
 *
 * Params:
 *	name (String): Name of the beer to request.
 *
 * Success:
 *	id (String): ID of the new beer request
 *
 * Possible Errors:
 *	No name specified
 *	There is no user currently logged in.
 *	The specified beer has already been requested.
 * 
 */
Parse.Cloud.define("beerAddRequest", function(request, response) {
	if (!request.user) {
		response.error("No user is logged in.");
		return;
	}
	
	var beerName = request.params.name;
	if (!beerName) {
		response.error("No beer was specified.");
		return;
	}
	
	var query = new Parse.Query(BeerRequest);
	query.equalTo("name", beerName);
	query.first().then(function(beerRequest) {
		if (beerRequest) {
			response.error("A beer with the name \"" + beerName + "\" has already been requested.");
			return;
		}
		
		beerRequest = new BeerRequest();
		beerRequest.set("name", beerName);
		beerRequest.set("user_id", request.user.id);
		beerRequest.set("votes", [request.user.id]);
		beerRequest.save().then(function(beerRequest) {
			response.success({id: beerRequest.id});
		},
		function(beerRequest, error) {
			response.error(error);
		});
	},
	function(beerRequest, error) {
		response.error(error);
	});
});

/* Clear a beer request.
 *
 * Params:
 *	id (String): The id of the request to remove
 *
 * Success: none
 *
 * Possible Errors:
 *	There is no user currently logged in.
 *	The current user does not have permission to delete a request.
 *	There is no request with the specified id.
 */
Parse.Cloud.define("beerRemoveRequest", function(request, response) {
	if (!request.user) {
		response.error("No user is logged in.");
		return;
	}
	if (!util.isUserAdmin(request.user)) {
		response.error("User does not have permission to delete a beer request.");
		return;
	}
	
	var requestId = request.params.id;
	if (!requestId) {
		response.error("No id was specified.");
		return;
	}
	
	var query = new Parse.Query(BeerRequest);
	query.equalTo("objectId", requestId);
	query.first().then(function(beerRequest) {
		if (!beerRequest) {
			response.error("No request exits with the id " + requestId + ".");
			return;
		}
		
		beerRequest.destroy().then(function(beerRequest) {
			console.log("Beer request " + requestId + " successfully deleted.");
			response.success();
		},
		function(beerRequest, error) {
			response.error(error);
		});
	},
	function(beerRequest, error) {
		response.error(error);
	});
});

var toggleVote = function(requestId, user, vote, response) {
	if (!user) {
		response.error("No user is logged in.");
		return;
	}
	
	if (!requestId) {
		response.error("No id was specified.");
		return;
	}
	
	var query = new Parse.Query(BeerRequest);
	query.equalTo("objectId", requestId);
	query.first().then(function(beerRequest) {
		if (!beerRequest) {
			response.error("No request exits with the id " + requestId + ".");
			return;
		}
		
		if (vote) {
			beerRequest.addUnique("votes", user.id);
		} else { // unvote
			beerRequest.remove("votes", user.id);
		}
		
		beerRequest.save().then(function(beerRequest) {
			var votes = beerRequest.get("votes");
			util.findUsers(votes).then(function(users) {
				response.success(util.infoForUsers(users));
			}, function(users, error) {
				response.error(error);
			});
		},
		function(beerRequest, error) {
			response.error(error);
		});
	},
	function(beerRequest, error) {
		response.error(error);
	});	
}

/* Vote for a beer.
 *
 * Params:
 *	id (String): ID of the beer request
 *
 * Success: Returns a JSON Array with a list of users who voted for the beer.
 *	id (String) - id of the user
 * 	name (String) - name of the user
 * 	picture (String) - URL of the user's avatar
 *
 * Possible Errors:
 *	There is no user currently logged in.
 *	There is no request with the specified id.
 * 
 */
Parse.Cloud.define("beerVoteForRequest", function(request, response) {
	toggleVote(request.params.id, request.user, true, response);
});

/* Unvote for a beer.
 *
 * Params:
 *	id (String): ID of the beer request
 *
 * Success: Returns a JSON Array with a list of users who voted for the beer.
 *	id (String) - id of the user
 * 	name (String) - name of the user
 * 	picture (String) - URL of the user's avatar
 *
 * Possible Errors:
 *	There is no user currently logged in.
 *	There is no request with the specified id.
 * 
 */
Parse.Cloud.define("beerUnvoteForRequest", function(request, response) {
	toggleVote(request.params.id, request.user, false, response);
});