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
    return apiRequest('/1/users/me');
}