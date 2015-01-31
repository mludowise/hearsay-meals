var util = require("cloud/util.js");

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
