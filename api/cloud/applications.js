// Convenience class
var ApplicationProperties = Parse.Object.extend("ApplicationProperties");

/* Get latest app
 * 
 * Params:
 *	platform (String): 'iOS' for iPhone
 *
 * Success:
 *	version (Number): The version number of the app
 *	url (String): URL to download the app
 *
 * Possible Errors:
 *	No platform specified.
 *	No application exists for that platform.
 */
Parse.Cloud.define("applicationsGetLatest", function(request, response) {
	var platform = request.params.platform;
	if (!platform) {
		response.error("No platform specified.");
		return;
	}
	
	var query = new Parse.Query(ApplicationProperties);
	query.equalTo("applicationType", platform);
	query.descending("latestVersion");
	query.first().then(function(appProperties) {
		if (!appProperties) {
			response.error("No application exists for the platform '" + platform + "'.");
			return;
		}
		
		response.success({
			version: appProperties.get("latestVersion"),
			url: appProperties.get("downloadUrl")
		});
	}, function(appProperties, error) {
		response.error(error);
	});
});