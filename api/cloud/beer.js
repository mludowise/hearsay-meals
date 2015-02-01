var util = require("cloud/util.js");

// Convenience classes
var BeerReequest = Parse.Object.extend("BeerRequest");
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
		response.error("A dinner order can only be cancelled when a user is logged in.");
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
		response.error("A dinner order can only be cancelled when a user is logged in.");
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

/* Marks the keg as filled with a specific beer.
 *
 * Params:
 *	name (String): Name of the beer
 *
 * Success: none
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
	
	var keg = new Keg();
	// TODO: User restricted ACL when adding Keg.
// 	keg.setACL(util.restrictedACL());
	keg.set("beerName", beerName)
	keg.set("kickedReports", []);
	keg.save().then(function(keg) {
		console.log("Keg updated to " + beerName + ".");
		response.success();
	},
	function(keg, error) {
		response.error(error);
	});
});

/* Marks the keg as filled by a specific beer requested.
 * The beer request will be removed.
 *
 * Params:
 *	requestId (String): The id of the beer request 
 *
 * Success: none
 *
 * Possible Errors:
 *	There is no user currently logged in.
 *	The current user does not have permission to fill the keg.
 *	There is no request with the specified id.
 */
Parse.Cloud.define("beerFillKegFromRequest", function(request, response) {
	response.success();
});

var possiblySucceed = function(response, results, result, numItems) {
	results.push(result);
	if (results.length == numItems) {
		response.success(results);
	}
}


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
	var query = new Parse.Query(BeerReequest);
	query.ascending("name");
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
					usersVoted.push(userMap[userId]);
				}
				results.push({
					id: beerRequest.id,
					name: beerRequest.get("name"),
					votes: usersVoted
				});
			}
			response.success(results);
		}, function(users, error) {
			response.error(error);
		});
	}, function(beerRequests, error) {
		response.error(error);
	});
});

/* Request a beer.
 *
 * Params:
 *	name (String): Name of the beer to request.
 *
 * Success: none
 *
 * Possible Errors:
 *	There is no user currently logged in.
 *	The specified beer has already been requested.
 * 
 */
Parse.Cloud.define("beerAddRequest", function(request, response) {
	response.success();
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
	response.success();
});
