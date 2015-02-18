var util = require("cloud/util.js");
var Mailgun = require('mailgun');

// Configure Mailgun 
var mailgunDomain = 'meals.hearsaysocial.com';
var mailgunAPIKey = 'key-354ba03f6a3d1296300537b75985e6e0';
Mailgun.initialize(mailgunDomain, mailgunAPIKey);

// Convenience classes
var Keg = Parse.Object.extend("Keg");

/* Checks if the keg has been reported kicked and sends an email notification to admins if
 * 	it has been newly reported. This should be run as a job every 15 minutes rather than 
 *	sending the email immediately in case the user immediately undoes the report.
 *
 * Params: none
 * 
 * Success: Relays Mailgun's success message
 * Possible Errors:
 *	Mailgun error
 *	No admins to send mail to
 */
Parse.Cloud.job("beerSendKickedNotification", function(request, status) {
	var query = new Parse.Query(Keg);
	query.descending("createdAt");
	query.first().then(function(keg) {
		if (keg && keg.get("kickedReports") && keg.get("kickedReports").length > 0 && !keg.get("sent_kicked_notice")) {
			util.getAdmins().then(function(users) {
				if (!users || users.length == 0) {
					status.error("No users with in the admin role. No email will be sent.");
					return;
				}
				
				var promises = [];
				for (var i in users) {
					var user = users[i];
					console.log("sending email to: " + user.getEmail());
					
					var promise = Mailgun.sendEmail({
						to: user.getEmail(),
						from: util.replyTo(),
						subject: "The Keg is Kicked!",
						text: "Someone just reported the keg is empty.\r\r"
							+ "Log into Hearsay Meals to see how many people have reported:\r"
							+ "http://meals.hearsaysocial.com/beer.html\r\r"
							+ "You are receiving this email because you are an administrator of Hearsay Meals."
					});
					promise.then(function(httpResponse) {
						console.log(httpResponse.text);
					}, function(httpResponse, error) {
						console.error(httpResponse.text);
					});
					promises.push(promise);
				}
				Parse.Promise.when(promises).then(function() {
					keg.set("sent_kicked_notice", true);
					keg.save(null, { useMasterKey: true });
					status.success();
				}, function() {
					status.error("Error sending emails.");
				});
			}, function(users, error) {
				status.error(error);
			});
		} else {
			console.log("Keg isn't kicked. Don't send email.");
			status.success();
		}
	}, function(keg, error) {
		status.error(error);
	});
});