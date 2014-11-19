$(document).ready(function() {
    var user = getCurrentUser();
    displayBeerRequests();

    var keg = getBeerOnTap().results[0];
    $('#beerOnTap').html('<h3>' + keg.beerName);
    if (keg.kickedReports.indexOf(user.objectId) > 0) {
        $('#kickedKeg').prop('checked', true);
    }
    displayKegKickedAlert(keg.kickedReports.length);

    $('#kickedKeg').on('click', function() {
        if (keg.kickedReports.indexOf(user.objectId) < 0) {
            keg.kickedReports.push(user.objectId);
        }
        else {
            var index = keg.kickedReports.indexOf(user.objectId);
            keg.kickedReports.splice(index, 1);
        }
        updateKickedKegRequests(keg);
    });

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

function getBeerOnTap() {
    var where = {
        order: '-createdAt',
        limit: 1
    };
    var results = apiRequest('/1/classes/Keg', where);
}

function updateKickedKegRequests(keg){
    apiRequest('/1/classes/Keg/'+ keg.objectId, {'kickedReports': keg.kickedReports}, 'PUT');
}

function saveBeerRequest(beerRequest){
    var requestResults = apiRequest('/1/classes/BeerRequest', beerRequest, 'POST');
    var vote = {
        user_id: beerRequest.user_id,
        beer_request_id: requestResults.objectId
    };
    var voteResults = apiRequest('/1/classes/BeerVotes', vote, 'POST');
    return requestResults;
}

function getBeerRequests(){
    var results = apiRequest('/1/classes/BeerRequest');
    for (var i = 0; i < results.results.length; i++){
        var request = results.results[i];
        request.votes = getBeerRequestVotes(request.objectId);
        results.results[i] = request;
    }
    return results.results;
}

function getBeerRequestVotes(beerRequestId){
    var where = {
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

function displayKegKickedAlert(numberOfReports){
    $('.kicked-count').val(numberOfReports);
    if (numberOfReports > 0){
        $('.kicked-count').show();
    }
    else
    {
        $('.kicked-count').hide();
    }
}