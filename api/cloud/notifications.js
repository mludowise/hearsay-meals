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
		if (!keg) {
			status.error("No keg");
			return;
		}
		
		var kickedReports = keg.get("kickedReports")
		if (keg.get("sent_kicked_notice") || !kickedReports || kickedReports.length == 0) {
			console.log("Keg isn't kicked. Don't send email.");
			status.success();
			return;
		}
		
		util.getAdmins().then(function(admins) {
			if (!admins || admins.length == 0) {
				status.error("No users with in the admin role. No email will be sent.");
				return;
			}
			
			var emailText = "The following people just reported that the keg is empty:\r";
			var usersPromise = util.findUsers(kickedReports)
			usersPromise.then(function(users) {
				for (var u in users) {
					var user = users[u];
					emailText += "\t" + user.get("name") + "\r";
				}
				return Parse.Promise.as(emailText);
			}, function(users, error) {
				console.error(error);
			}).then(function(emailText) {
				emailText += "\r"
							+ "Log into Hearsay Meals to verify:\r"
							+ "http://meals.hearsaysocial.com/beer.html\r\r"
							+ "------------------------------------------------------------------------------------------------------------------------\r"
							+ "You are receiving this email because you are an administrator of Hearsay Meals.\r"
							+ "If you no longer wish to receive these emails, please contact hearsaymeals-dev@hearsaycorp.com.";
				
				var promises = [];
				for (var i in admins) {
					var admin = admins[i];
					console.log("Sending email to: " + admin.getEmail());
				
					var promise = Mailgun.sendEmail({
						to: admin.getEmail(),
						from: util.replyTo(),
						subject: "The Keg is Kicked!",
						text: emailText
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
			})
		}, function(users, error) {
			status.error(error);
		});
	}, function(keg, error) {
		status.error(error);
	});
});