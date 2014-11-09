var parseApiUrl = "https://api.parse.com";

function apiRequest(url, data, method) {
    if (typeof method === "undefined"){
        method = "GET";
    }
    if (typeof data === "undefined"){
        data = {};
    }

    if ($.inArray(method, ['POST', 'PUT']) >= 0){
        data = JSON.stringify(data);
        contentType = 'application/json';
    }
    else {
        contentType = 'application/x-www-form-urlencoded; charset=UTF-8';
    }

    var results = null;

    var headers = {
        'X-Parse-Application-Id': 'myq9zbMzdkBqqEyudRcwIR5yxnmwihlslqUvYh34',
        'X-Parse-REST-API-Key': '8Zwn2jGVUZEimJ9YYJUorF305QCAg9qZaWsUVVPZ'
    };

    var sessionToken = localStorage.getItem('sessionToken');

    if (sessionToken !== null){
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
        success: function(data, status, jqXHR){
            results = data;
        }
    });

    return results;
}

function getCurrentUser(){
    results = apiRequest('/1/users/me');
    return results;
}

function findUser(id){
    results = apiRequest('/1/users/' + id);
    return results;
}

function userLogin(email){
    var data = {
        username: email,
        password: 'password'
    };
    results = apiRequest('/1/login/', data);
    return results;
}

function userSignedIn(){
    var sessionToken = localStorage.getItem('sessionToken');
    return sessionToken !== null;
}

function onSignInCallback(response) {
    console.log(response);
    key = "AIzaSyAW7z4SEmncGb9ElHfWlCOn6gejEPm0vHo";
    if (response.status.signed_in) {
        $('#gConnect').hide();
        if (!userSignedIn()){
            gapi.client.load('oauth2', 'v2', function() {
              gapi.client.oauth2.userinfo.get().execute(function(resp) {
                if (resp.hd !== 'hearsaycorp.com') {
                    alert('You must have a Hearsay email to use this app');
                    return;
                }
                localStorage.setItem('email', resp.email);
                localStorage.setItem('name', resp.name);
                var storedEmail = localStorage.getItem('email');
                var user = null;
                if (storedEmail !== null)
                {
                    user = userLogin(storedEmail);
                }
                else
                {
                    user = userLogin(resp.email);
                    if (user === null){
                        var data = {
                            email : resp.email,
                            password : 'password',
                            username : resp.email,
                            name : resp.name,
                            picture : resp.picture
                        };
                        user = apiRequest('/1/users', data, 'POST');
                    }
                }
                localStorage.setItem('sessionToken', user.sessionToken);
              });
            });
        }
    }
}