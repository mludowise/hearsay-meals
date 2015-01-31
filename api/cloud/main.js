// moment.js required for timezone manipulation
require("cloud/moment.min.js");
var moment = require("cloud/moment-timezone-with-data-2010-2020.min.js");

var find = function(objects, param, value) {
	for (var i in objects) {
		var object = objects[i];
		if (object.get(param) == value) {
			return object;
		}
	}
	return null;
}

var userInfo = function(user, includePrefs) {
	var user = {
		id: user.id,
		name: user.get("name"),
		picture: user.get("picture"),
	};
	if (includePrefs) {
		user.preferences = user.get("preferences");
		user.preferenceNote = user.get("preference_note");
	}
	return user;
}

/* Dinner
-------------------------------------------------- */

// Constants we'll be using to calculate when to order dinner
var DINNER_ORDER_TIMEZONE = "US/Pacific";
var DINNER_ORDER_DEADLINE = {
	hours: 16,
	minutes: 0
};

// Convenience class
var DinnerOrder = Parse.Object.extend("Dinner");

// Utility to generate a Date object for the dinner order given a date.
// Will set the time of the date to the dinner order deadline.
// If dateParams are provided, it will set the day/month/year to the appropriate date.
var dinnerOrderDate = function(dateParams) {
	var m = null;
	if (dateParams) {
		m = moment(new Date(dateParams.year, dateParams.month, dateParams.day));
	} else {
		m = moment();
	}
	var formattedDate = m.format("YYYY-MM-DD") 
		+ " " +  DINNER_ORDER_DEADLINE.hours + ":" +  DINNER_ORDER_DEADLINE.minutes
	
	return moment.tz(formattedDate, DINNER_ORDER_TIMEZONE).toDate();
}

/* Get dinner configuration
 * 
 * Params: none
 *
 * Success returns a JSON object consisting of:
 *	minPeople (Integer): The minimum number of people required to order dinner.
 *	orderDeadline: a JSON object representing the deadline for ordering dinner, consisting of:
 *		timeZone (String): The name of the timezone for which the deadline is in (eg. "US/Pacific").
 *		time (JSON): The time of day for the order deadline.
 *			hours (Integer)
 *			minutes (Integer)
 *
 * Possible Errors: none
 */
Parse.Cloud.define("dinnerGetConfigs", function(request, response) {
	response.success({ 
		minPeople: 4,
		orderDeadline: {
			timeZone: DINNER_ORDER_TIMEZONE,
			time:  DINNER_ORDER_DEADLINE
		}
	});
});

/* Order dinner for the current user
 * 
 * Params:
 *	specialRequest (String)
 *	date (Date, Optional): Date for which to order dinner. If null, dinner will be ordered for today.
 *
 * Success: none
 *
 * Possible Errors:
 * 	Invalid user
 * 	User has already ordered dinner for the specified date.
 */
Parse.Cloud.define("dinnerMakeOrder", function(request, response) {
	if (!request.user) {
		response.error("A dinner order can only be made when a user is logged in.");
		return;
	}
	
	var orderDate = dinnerOrderDate(request.params.date);
	console.log("Order Date: " + orderDate);

	var query = new Parse.Query(DinnerOrder);
	query.equalTo("order_date", orderDate);
	query.equalTo("user_id", request.user.id);
	query.first().then(function(order) {
		if (order) {
			response.error("User " + request.user.getEmail() + " has already ordered dinner for " + orderDate + ".");
		} else {
			var acl = new Parse.ACL(request.user);
			acl.setRoleWriteAccess("Administrator", true);
		
			var order = new DinnerOrder();
			order.set("user_id", request.user.id);
			order.set("order_date", orderDate);
			order.set("special_request", request.params.specialRequest);
			order.setACL(acl);
			return order.save().then(function(order) {
				console.log("Order " + order.id + " created.");
				response.success();
			}, function(order, error) {
				response.error(error);
			});
		}
	},
	function(order, error) {
		response.error(error);
	});
});

/* Cancel dinner order for the current user
 *
 * Params:
 *	date (Date, Optional): Date for which to cancel order. If null, dinner will be cancelled for today.
 *
 * Success: none
 *
 * Possible Errors:
 * 	Invalid user
 * 	User has not ordered dinner for the specified date.
 */
Parse.Cloud.define("dinnerCancelOrder", function(request, response) {
	if (!request.user) {
		response.error("A dinner order can only be cancelled when a user is logged in.");
		return;
	}
	
	var orderDate = dinnerOrderDate(request.params.date);
	console.log("Order Date: " + orderDate);

	var query = new Parse.Query(DinnerOrder);
	query.equalTo("order_date", orderDate);
	query.equalTo("user_id", request.user.id);
	query.first().then(function(order) {
		if (!order) {
			response.error("User " + request.user.getEmail() + " has not ordered dinner for " + orderDate + ".");
		} else {
			return order.destroy().then(function(order) {
				console.log("Order " + order.id + " deleted.");
				response.success();
			}, function(order, error) {
				response.error(error);
			});
		}
	},
	function(order, error) {
		response.error(error);
	});
});

/* Returns a list of users who ordered dinner today
 *
 * Params:
 *	date (JSON, Optional): Date for which to get orders for. If null, return orders for today.
 *		day (Integer): Day of month, ranging 1-31
 *		month (Integer): Ranging 0-11
 *		year (Integer)
 *
 * Success returns: An array of JSON objects representing each person
 * 	specialRequest (String) - A special request for today's dinner order made by the user
 *	user (JSON):
 *		id (String) - id of the user
 * 		name (String) - name of the user
 * 		picture (String) - URL of the user's avatar
 * 		preferences (Array[Int]) - An array of integers representing the user's dietary preferences
 *	 	preferenceNote (String) - The special dietary restriction note for the user
 *
 * Possible Errors: none
 */
Parse.Cloud.define("dinnerGetOrders", function(request, response) {
	var orderDate = dinnerOrderDate(request.params.date);
	console.log("Order Date: " + orderDate);

	var query = new Parse.Query(DinnerOrder);
	query.equalTo("order_date", orderDate);
	query.find().then(function(orders) {
		if (!orders) {
			response.success([]);
		} else {	
			// TODO: Change database schema to make user a relation so this code is much simpler
		
			var userIds = [];
			for (var i in orders) {
				var order = orders[i];
				var userId = order.get("user_id");
				userIds.push(userId);
			}
		
			var userQuery = new Parse.Query(Parse.User);
			userQuery.ascending("name");
			userQuery.containedIn("objectId", userIds);
			userQuery.find().then(function(users) {
				var results = [];
				for (var i in users) {
					var user = users[i];
					var order = find(orders, "user_id", user.id);
					results.push({
						specialRequest: order.get("special_request"),
						user: userInfo(user, true)
					});
				}
				response.success(results);
			},
			function(error) {
				response.error(error);
			});
		}
	},
	function(error) {
		response.error(error);
	});
});


/* Beer
-------------------------------------------------- */

// Convenience classes
var BeerReequest = Parse.Object.extend("BeerRequest");
var Keg = Parse.Object.extend("Keg");

/* Returns the beer that's on tap
 *
 * Params: none
 *
 * Success: Returns JSON object of the most recent beer on tap or null if there isn't one.
 *	name (String): Name of the beer on tap
 *	filled (Date): Date that the keg was filled
 *	kickedReport (JSON Array): A list of users who reported the keg was kicked.
 *		id (String) - id of the user
 * 		name (String) - name of the user
 * 		picture (String) - URL of the user's avatar
 *
 * Possible Errors: none
 */
Parse.Cloud.define("beerOnTap", function(request, response) {
	response.success();
});

/* Marks that the current user reported the keg was kicked.
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
 */
Parse.Cloud.define("beerReportKicked", function(request, response) {
	response.success();
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
 */
Parse.Cloud.define("beerUnreportKicked", function(request, response) {
	response.success();
});

/* Marks the keg as filled with a specific beer.
 *
 * Params:
 *	name (String): Name of the beer
 *
 * Success: none
 *
 * Possible Errors:
 *	The current user does not have permission to fill the keg.
 */
Parse.Cloud.define("beerFillKeg", function(request, response) {
	response.success();
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
		var userQuery = new Parse.Query(Parse.User);
		userQuery.ascending("name");
		userQuery.containedIn("objectId", userIds);
		userQuery.find().then(function(users) {
			// Find all the users who voted
			for (var u in users) {
				var user = users[u];
				userMap[user.id] = userInfo(user, false);
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
