$(document).ready(function() {
    var user = getCurrentUser();
    displayBeerRequests();
    var keg = getBeerOnTap().results[0];
    $('#beerOnTap').html('<h3>' + keg.beerName);
    if (keg.kickedReports.indexOf(user.objectId) > 0) {
        $('#kickedKeg').prop('checked', true);
    }
    if (keg.kickedReports.length > 0) {
        var alert = '<div class="alert alert-danger" role="alert">' + keg.kickedReports.length + ' people reported the keg is kicked</div>';
        $('.alerts').html(alert);
    }
    $('#kickedKeg').on('click', function() {
        if (keg.kickedReports.indexOf(user.objectId) < 0) {
            keg.kickedReports.push(user.objectId);
            var resp = apiRequest('/1/classes/Keg/'+ keg.objectId, {'kickedReports': keg.kickedReports}, 'PUT')
            if (resp) {
                var alert = '<div class="alert alert-danger" role="alert">' + keg.kickedReports.length + ' people reported the keg is kicked</div>';
                $('.alerts').html(alert);
            }
        }
        else {
            var index = keg.kickedReports.indexOf(user.objectId);
            keg.kickedReports.splice(index, 1);
            var resp = apiRequest('/1/classes/Keg/'+ keg.objectId, {'kickedReports': keg.kickedReports}, 'PUT');
            if (resp) {
                var alert = '<div class="alert alert-danger" role="alert">' + keg.kickedReports.length + ' people reported the keg is kicked</div>';
                $('.alerts').html(alert);
            }                
        }
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

function getBeerOnTap() {
    return apiRequest('/1/classes/Keg');
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