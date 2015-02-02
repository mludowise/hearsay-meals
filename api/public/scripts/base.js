var parseApiUrl = "https://api.parse.com";

function updateLoginInfo() {
	var user = Parse.User.current();
    if (user == null && window.location.pathname != "/index.html") {
        window.location.href = "index.html";
        return;
    }
    if (user.getPicture()) {
        $('li.user').prepend("<img src='" + user.getPicture() + "' width='30px'>");
    }
    $('li.user p').text(user.getName());
}

function currentUserIsAdmin() {
	var user = Parse.User.current();
	return user != null && user.isAdmin();
}

function showAdmin() {
    if (currentUserIsAdmin()) {
        $('.admin').show();
    } else {
        $('.admin').hide();
    }
}

function onSignInCallback(response) {
	key = googleKey;
	if (response.status && response.status.signed_in) {
		$('#gConnect').hide();
		var pUser = Parse.User.current();
		if (!pUser) {
			gapi.client.load('oauth2', 'v2', function () {
				gapi.client.oauth2.userinfo.get().execute(function (resp) {
					if (resp.hd !== 'hearsaycorp.com') {
						alert('You must have a Hearsay email to use this app');
						return;
					}
					Parse.User.logIn(resp.email, "password").then(function(user) {
						window.location.href = "dinner.html";
					},
					function(error) {
						Parse.User.signUp(resp.email, "password", {
								email: resp.email,
								name: resp.name,
								picture: resp.picture,
								admin: false,
								preferences: [0]
						}).then(function(user) {
							window.location.href = "dinner.html";
						});
					});
				});
			});
		} else {
            window.location.href = "dinner.html";
		}
	}
}

function checkForMobile() {
	var iOS = /(iPhone|iPod)/g.test(navigator.userAgent);
   	if (iOS) {
		Parse.Cloud.run("applicationsGetLatest", {platform: "iOS"}).then(function(response) {
			$banner = $("#banner");
			$alert = $('<div class="alert alert-dismissible fade in" role="alert">');
			$alert.append('<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">×</span></button>');
			$alert.append('<img class="ios_app_icon" src="images/app_icon.png"/>');
			$banner.append($alert);
			$description = $('<span class="mobile-banner-description">Order dinner on the go!</span>'); 
			$alert.append($description)
			$alert.append('<a class="mobile-banner-download" href="' + response.url + '" target="_blank">INSTALL</a>');
		}, function(error) {
			console.error(error);
		});
	}
}

$(function () {	
	var parseKeys = getParseKeys();
	Parse.initialize(parseKeys["applicationId"], parseKeys["javascriptKey"]);
	
	var User = Parse.User.extend({
		getEmail: function() {
			return this.get("email");
		},
		getPicture: function() {
			return this.get("picture");
		},
		getName: function() {
			return this.get("name");
		},
		isAdmin: function() {
			return this.get("admin");
		},
		getPreferences: function() {
			return this.get("preferences");
		},
		setPreferences: function(preferences) {
			this.set("preferences", preferences);
		},
		getPreferenceNote: function() {
			return this.get("preference_note");
		},
		setPreferenceNote: function(preferenceNote) {
			this.set("preference_note", preferenceNote);
		}
	});
});

$(document).ready(function () {
	updateLoginInfo();
    showAdmin();
	checkForMobile();	
});