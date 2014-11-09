$(document).ready(function() {
    var user = getCurrentUser();
    displayBeerRequests();

    $('#request-beer').click(function(){
        var beerType = $('#beerType').val();
        var beerRequest = {
            name: beerType,
            user_id: user.objectId
        };
        beerRequestResult = saveBeerRequest(beerRequest);
        displayBeerRequests();
    });
});

function saveBeerRequest(beerRequest){
    requestResults = apiRequest('/1/classes/BeerRequest', beerRequest, 'POST');
    vote = {
        user_id: beerRequest.user_id,
        beer_request_id: requestResults.objectId
    };
    voteResults = apiRequest('/1/classes/BeerVotes', vote, 'POST');
    return requestResults;
}

function getBeerRequests(){
    var results = apiRequest('/1/classes/BeerRequest');
    for (var i = 0; i < results.results.length; i++){
        request = results.results[i];
        request.votes = getBeerRequestVotes(request.objectId);
        results.results[i] = request;
    }
    return results.results;
}

function getBeerRequestVotes(beerRequestId){
    where = {
        where: {
            beer_request_id: beerRequestId
        }
    };
    var results = apiRequest('/1/classes/BeerVotes', where);
    return results.results;
}

function displayBeerRequests(){
    var beerRequests = getBeerRequests();
    var $tbody = $("#beer-request-list tbody");
    $tbody.empty();
    for (var i = 0; i < beerRequests.length; i++){
        var request = beerRequests[i];
        var $row = $('<tr>');
        var $beerType = $('<td>').text(request.name);
        var $voteCount = $('<td>').text(request.votes.length);
        $row.append($beerType).append($voteCount);
        $tbody.append($row);
    }
}