var parseApiUrl = "https://api.parse.com";

function getPreferenceDisplay(id) {
	switch(id) {
		case 0:
			return {
				label: "Omnivore",
				icon: "icon-omnivore"
			};
		case 1:
			return {
				label: "Vegetarian",
				icon: "icon-vegetarian" 
			};
		case 2:
			return {
				label: "Vegan",
				icon: "icon-vegan" 
			};
		case 3:
			return {
				label: "No Gluten",
				icon: "icon-gluten" 
			};
		case 4:
			return {
				label: "Pescetarian",
				icon: "icon-pescetarian" 
			};
		case 5:
			return {
				label: "No Nuts",
				icon: "icon-nuts" 
			};
		case 6:
			return {
				label: "No Soy",
				icon: "icon-soy" 
			};
		case 7:
			return {
				label: "No Eggs",
				icon: "icon-eggs" 
			};
		case 8:
			return {
				label: "No Dairy",
				icon: "icon-dairy" 
			};
		case 9:
			return {
				label: "No Shellfish",
				icon: "icon-shellfish" 
			};
		case 10:
			return {
				label: "No Fish",
				icon: "icon-fish" 
			};
		case 11:
			return {
				label: "No Pork",
				icon: "icon-pork" 
			};
		case 12:
			return {
				label: "No Beef",
				icon: "icon-beef" 
			};
		case 13:
			return {
				label: "No Lamb",
				icon: "icon-lamb" 
			};
		case 14:
			return {
				label: "No Poultry",
				icon: "icon-poultry" 
			};
		case 15:
			return {
				label: "No Garlic",
				icon: "icon-garlic" 
			};
		default:
			return null;
	}
}

function getPreferencesDisplay(ids) {
	var idsCopy = ids;
	idsCopy.sort(function(a, b) {
		var a2 = a == 3 ? 4 : a == 4 ? 3 : a;
		var b2 = b == 3 ? 4 : b == 4 ? 3 : b;
		return a2-b2;
	});
	var preferenceDisplays = [];
	for (var i in idsCopy) {
		var id = ids[i];
		var display = getPreferenceDisplay(id)
		if (display) {
			preferenceDisplays.push(display);
		}
	}
	return preferenceDisplays;
}

function updateLoginInfo() {
	var user = Parse.User.current();
    if (user == null) {
    	if (window.location.pathname != "/index.html") {
        	window.location.href = "index.html";
        }
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

function showPreferencesHelpTip() {
	if (typeof(Storage) !== "undefined" && $('#preference-nav-item').is(":visible") ) {
		$('#preference-nav-item').popover({
			content: 'More dietary preferences available!',
			trigger: 'manual',
			placement: 'bottom',
		});
		setTimeout(function() {
			if (!localStorage.visitedPreferences) {
				$('#preference-nav-item').popover('show');
			} else {
				$('#preference-nav-item').popover('destroy');
			}
		}, 1500);
	}
}

$(document).ready(function () {
	updateLoginInfo();
    showAdmin();
	checkForMobile();
	showPreferencesHelpTip();
});