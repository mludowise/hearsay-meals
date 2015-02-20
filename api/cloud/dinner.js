var util = require("cloud/util.js");
var moment = require("moment");

// Constants we'll be using to calculate when to order dinner
var DINNER_ORDER_DEADLINE = {
	hours: 16,
	minutes: 0
};

// Convenience class
var DinnerOrder = Parse.Object.extend("Dinner");

// Utility to generate a Date object for the dinner order given a date.
// If dateParams are provided, it will set the day/month/year to the appropriate date.
var getDate = function(dateParams) {
	return new Date(dateParams.year, dateParams.month, dateParams.day);
}

/* Get dinner configuration
 * 
 * Params: none
 *
 * Success returns a JSON object consisting of:
 *	minPeople (Integer): The minimum number of people required to order dinner.
 *	deadline (JSON): The time of day for the order deadline.
 *		hours (Integer)
 *		minutes (Integer)
 *
 * Possible Errors: none
 */
Parse.Cloud.define("dinnerGetConfigs", function(request, response) {
	response.success({ 
		minPeople: 4,
		deadline: DINNER_ORDER_DEADLINE
	});
});

/* Order dinner for the current user or update special request for order
 * 
 * Params:
 *	specialRequest (String, Optional)
 *	date (JSON): Date for which to order dinner.
 *		day (Integer): Day of month, ranging 1-31
 *		month (Integer): Ranging 0-11
 *		year (Integer)
 *
 * Success: none
 *
 * Possible Errors:
 * 	Invalid user
 *	No date provided
 */
Parse.Cloud.define("dinnerMakeOrder", function(request, response) {
	if (!request.user) {
		response.error("No user is logged in.");
		return;
	}
	if (!request.params.date) {
		response.error("No date provided.");
		return;
	}
	
	var orderDate = getDate(request.params.date);
	console.log("Order Date: " + orderDate);

	var query = new Parse.Query(DinnerOrder);
	query.equalTo("order_date", orderDate);
	query.equalTo("user_id", request.user.id);
	console.log(request.params.specialRequest);
	query.first().then(function(order) {
		if (order) {
			console.log("User " + request.user.getEmail() + " has already ordered dinner for " + orderDate + ".");
			order.set("special_request", request.params.specialRequest);
		} else {
			var acl = new Parse.ACL(request.user);
			acl.setPublicReadAccess(true);
			acl.setRoleWriteAccess("Administrator", true);
		
			order = new DinnerOrder();
			order.set("user_id", request.user.id);
			order.set("order_date", orderDate);
			order.set("special_request", request.params.specialRequest);
			order.setACL(acl);
		}
		order.save().then(function(order) {
			console.log("Order " + order.id + " saved.");
			response.success();
		}, function(order, error) {
			response.error(error);
		});
	},
	function(order, error) {
		response.error(error);
	});
});

/* Cancel dinner order for the current user
 *
 * Params:
 *	date (JSON): Date for which to order dinner.
 *		day (Integer): Day of month, ranging 1-31
 *		month (Integer): Ranging 0-11
 *		year (Integer)
 *
 * Success: none
 *
 * Possible Errors:
 * 	Invalid user
 *	No date provided
 */
Parse.Cloud.define("dinnerCancelOrder", function(request, response) {
	if (!request.user) {
		response.error("No user is logged in.");
		return;
	}
	if (!request.params.date) {
		response.error("No date provided.");
		return;
	}
	
	var orderDate = getDate(request.params.date);
	console.log("Order Date: " + orderDate);

	var query = new Parse.Query(DinnerOrder);
	query.equalTo("order_date", orderDate);
	query.equalTo("user_id", request.user.id);
	query.first().then(function(order) {
		if (!order) {
			console.log("User " + request.user.getEmail() + " has not ordered dinner for " + orderDate + ".");
			response.success();
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
 *	date (JSON): Date for which to get orders for.
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
 * Possible Errors:
 *	No date provided
 */
Parse.Cloud.define("dinnerGetOrders", function(request, response) {
	if (!request.params.date) {
		response.error("No date provided.");
		return;
	}
	
	var orderDate = getDate(request.params.date);
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
					var order = util.find(orders, "user_id", user.id);
					results.push({
						specialRequest: order.get("special_request"),
						user: util.userInfo(user, true)
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
