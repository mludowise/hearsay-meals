$(document).ready(function() {
    var user = getCurrentUser();

    $('#request-beer').click(function(){
        var beerType = $('.beerType').val();
        var beerRequest = {
            name: beerType,
            user: user
        };
        saveBeerRequest(beerRequest);
    });

    $('#show-requests').click(function(){
        var beerRequests = getBeerRequests();
        alert("Successfully retrieved " + beerRequests.length + " beer requests.");
        // Do something with the returned Parse.Object values
        for (var i = 0; i < beerRequests.length; i++) {
            var object = beerRequests[i];
            alert(object.id + ' - ' + object.name);
        }
        return false;
    });
});

function saveBeerRequest(beerRequest){
    return apiRequest('/1/classes/BeerRequest', beerRequest, 'POST');
}

function getBeerRequests(){
    results = apiRequest('/1/classes/BeerRequest');
    return results.results;
}