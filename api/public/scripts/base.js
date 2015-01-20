var parseApiUrl = "https://api.parse.com";

function updateLoginInfo(user) {
    if (!user) {
        window.location.href = "index.html";
        return;
    }
    if (user.picture) {
        $('li.user').prepend("<img src='" + user.picture + "' width='30px'>");
    }
    $('li.user p').text(user.name);
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

 	var headers = getParseKeys();

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

function getCurrentUser() {
    results = apiRequest('/1/users/me');
    return results;
}

function currentUserIsAdmin() {
    var user = getCurrentUser();
    var isAdmin = false;
    // Rather than return user.admin
    // we only change the value in case this is not a valid value
    if (user && user.admin === true) {
        isAdmin = user.admin;
    }
    return isAdmin;
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

function userLogin(email) {
    var data = {
        username: email,
        password: 'password'
    };
    results = apiRequest('/1/login/', data);
    return results;
}

function userSignedIn() {
    var sessionToken = localStorage.getItem('sessionToken');
    return sessionToken !== null;
}

function onSignInCallback(response) {
    key = googleKey;
    if (response.status.signed_in) {
        $('#gConnect').hide();
        if (!userSignedIn()) {
            gapi.client.load('oauth2', 'v2', function () {
                gapi.client.oauth2.userinfo.get().execute(function (resp) {
                    if (resp.hd !== 'hearsaycorp.com') {
                        alert('You must have a Hearsay email to use this app');
                        return;
                    }
                    var storedEmail = localStorage.getItem('email');
                    var user = null;
                    if (storedEmail !== null) {
                        user = userLogin(storedEmail);
                    } else {
                        user = userLogin(resp.email);
                        if (user === null) {
                            var data = {
                                email: resp.email,
                                password: 'password',
                                username: resp.email,
                                name: resp.name,
                                picture: resp.picture,
                                admin: false,
                                preferences: [0]
                            };
                            user = apiRequest('/1/users', data, 'POST');
                        }
                    }
                    localStorage.setItem('email', resp.email);
                    localStorage.setItem('name', resp.name);
                    localStorage.setItem('sessionToken', user.sessionToken);
                    window.location.href = "dinner.html";
                });
            });
        } else {
            window.location.href = "dinner.html";
        }
    }
}

$(document).ready(function () {
    showAdmin();
    
	var iOS = /(iPhone|iPod)/g.test( navigator.userAgent );
 	if (iOS) {
    	$banner = $("#banner");
    	$alert = $('<div class="alert alert-dismissible fade in" role="alert">');
    	$alert.append('<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">×</span></button>');
    	$alert.append('<img class="ios_app_icon" src="images/app_icon.png"/>');
    	$banner.append($alert);
    	$description = $('<span class="mobile-banner-description">Order dinner on the go!</span>'); 
    	$alert.append($description)
     	$alert.append('<a class="mobile-banner-download" href="#">Download</a>');
    }
});