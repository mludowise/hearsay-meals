var parseApiUrl = "https://api.parse.com";

function apiRequest(url, method, data) {
    if (typeof method === "undefined"){
        method = "GET";
    }
    if (typeof data === "undefined"){
        data = {};
    }

    var results = null;

    var headers = {
        'X-Parse-Application-Id': 'myq9zbMzdkBqqEyudRcwIR5yxnmwihlslqUvYh34',
        'X-Parse-REST-API-Key': '8Zwn2jGVUZEimJ9YYJUorF305QCAg9qZaWsUVVPZ'
    }

    $.ajax({
        url: parseApiUrl + url,
        type: method,
        data: data,
        headers: headers,
        contentType: 'application/json',
        dataType: 'json',
        async: false,
        success: function(data, status, jqXHR){
            results = data;
        }
    });

    return results;
}

function getCurrentUser(){
    return null;
    return apiRequest('/1/users/me');
}