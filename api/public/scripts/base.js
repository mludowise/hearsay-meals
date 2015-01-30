var parseApiUrl = "https://api.parse.com";

function updateLoginInfo(user) {
    if (user == null) {
        window.location.href = "index.html";
        return;
    }
    if (user.getPicture()) {
        $('li.user').prepend("<img src='" + user.getPicture() + "' width='30px'>");
    }
    $('li.user p').text(user.getName());
    showAdmin();
}

function apiRequest(url, data, method) {
    if (typeof method === "undefined") {
        method = "GET";
    }
    if (typeof data === "undefined") {
        data = {};
    }

    if ($.inArray(method, ['POST', 'PUT']) >= 0) {
        data = JSON.stringify(data);
        contentType = 'application/json';
    } else {
        contentType = 'application/x-www-form-urlencoded; charset=UTF-8';
    }

    var results = null;
	var parseKeys = getParseKeys();
 	var headers = {
		'X-Parse-Application-Id': parseKeys.applicationId,
    	'X-Parse-REST-API-Key': parseKeys.restKey
 	};

    var sessionToken = localStorage.getItem('sessionToken');

    if (sessionToken !== null) {
        headers['X-Parse-Session-Token'] = sessionToken;
    }

    $.ajax({
        url: parseApiUrl + url,
        type: method,
        data: data,
        headers: headers,
        contentType: contentType,
        dataType: 'json',
        async: false,
        success: function (data, status, jqXHR) {
            results = data;
        }
    });

    return results;
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

function findUser(id) {
    results = apiRequest('/1/users/' + id);
    return results;
}

function onSignInCallback(response) {
//     key = googleKey;
//     if (response.status.signed_in) {
//         $('#gConnect').hide();
//         if (Parse.User.current() == null) {
//             gapi.client.load('oauth2', 'v2', function () {
//                 gapi.client.oauth2.userinfo.get().execute(function (resp) {
//                     if (resp.hd !== 'hearsaycorp.com') {
//                         alert('You must have a Hearsay email to use this app');
//                         return;
//                     }
//                     var storedEmail = localStorage.getItem('email');
//                     var user = null;
//                     if (storedEmail !== null) {
//                         user = userLogin(storedEmail);
//                     } else {
//                         user = userLogin(resp.email);
//                         if (user === null) {
//                             var data = {
//                                 email: resp.email,
//                                 password: 'password',
//                                 username: resp.email,
//                                 name: resp.name,
//                                 picture: resp.picture,
//                                 admin: false,
//                                 preferences: [0]
//                             };
//                             user = apiRequest('/1/users', data, 'POST');
//                         }
//                     }
//                     localStorage.setItem('email', resp.email);
//                     localStorage.setItem('name', resp.name);
//                     localStorage.setItem('sessionToken', user.sessionToken);
//                     window.location.href = "dinner.html";
//                 });
//             });
//         } else {
//             window.location.href = "dinner.html";
//         }
//     }
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
	var iOS = /(iPhone|iPod)/g.test( navigator.userAgent );
   	if (iOS) {
        var dinnerRequest = apiRequest('/1/classes/Dinner', {where: whereClause}, 'GET');
		var whereClause = {
			'applicationType': 'iOS',
			'applicationId': 'com.hearsaysocial.HearsayMeals'
		};
		var results = apiRequest('/1/classes/ApplicationProperties', {where: whereClause, order: 'latestVersion'}, 'GET');
		if (results != null && results.results != null && results.results.length > 0) {
			var appProperties = results.results[results.results.length - 1]
			$banner = $("#banner");
			$alert = $('<div class="alert alert-dismissible fade in" role="alert">');
			$alert.append('<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">×</span></button>');
			$alert.append('<img class="ios_app_icon" src="images/app_icon.png"/>');
			$banner.append($alert);
			$description = $('<span class="mobile-banner-description">Order dinner on the go!</span>'); 
			$alert.append($description)
			$alert.append('<a class="mobile-banner-download" href="' + appProperties.downloadUrl + '" target="_blank">INSTALL</a>');
     	}
      }
});