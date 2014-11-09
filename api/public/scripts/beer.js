$(document).ready(function() {
    var user = getUser();

    $('#request-beer').click(function(){
        var beerType = $('.beerType').val();
        var beerRequest = {
            'name': beerType,
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
    return apiRequest('/1/classes/BeerRequest', 'POST', beerRequest);
}

function getBeerRequests(){
    return apiRequest('/1/classes/BeerRequest');
}