require("cloud/beer.js");
require("cloud/dinner.js");
require("cloud/applications.js");
require("cloud/notifications.js");

var Mailgun = require('mailgun');
Mailgun.initialize('meals.hearsaysocial.com', 'key-354ba03f6a3d1296300537b75985e6e0');

Parse.Cloud.define("sendMail", function(request, response) {
		console.log(request.user.getEmail());
		Mailgun.sendEmail({
			to: request.user.getEmail(),
			from: "meals@meals.hearsaysocial.com",
			subject: "The Keg is Kicked!",
			text: "Someone has reported the keg has been kicked.\r\r"
				+ "For more information:\r"
				+ "http://meals.hearsaysocial.com/beer.html"
		}, {
			success: function(httpResponse) {
				console.log(httpResponse.text);
				response.success();
			},
			error: function(httpResponse) {
				console.error(httpResponse.text);
				response.error("Uh oh, something went wrong");
			}
		});
});