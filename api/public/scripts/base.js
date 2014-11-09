var parseApiUrl = "https://api.parse.com";

function apiRequest(url, method, data) {
    if (typeof method === "undefined"){
        method = "GET";
    }
    if (typeof data === "undefined"){
        data = {};
    }

    var results = null;

    $.ajax({
        url: parseApiUrl + url,
        type: method,
        data: data,
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