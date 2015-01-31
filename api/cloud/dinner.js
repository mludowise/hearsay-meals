var util = require("cloud/util.js");

// moment.js required for timezone manipulation
require("cloud/moment.min.js");
var moment = require("cloud/moment-timezone-with-data-2010-2020.min.js");

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
