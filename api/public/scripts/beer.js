$(document).ready(function() {
    var user = getCurrentUser();

    $('#request-beer').click(function(){
        var beerType = $('.beerType').val();
        var beerRequest = {
            name: beerType,
        };
        saveBeerRequest(beerRequest);
    });

    $('#show-requests').click(function(){
        var beerRequests = getBeerRequests();
    });
});

function saveBeerRequest(beerRequest){
    return apiRequest('/1/classes/BeerRequest', beerRequest, 'POST');
}

function getBeerRequests(){
    return apiRequest('/1/classes/BeerRequest');
}