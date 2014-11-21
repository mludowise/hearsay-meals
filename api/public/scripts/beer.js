$(document).ready(function() {
    var user = getCurrentUser();
    updateLoginInfo(user);
    displayBeerRequests();

    var keg = getBeerOnTap();
    displayBeerOnTap(keg);
    if (keg.kickedReports.indexOf(user.objectId) >= 0) {
        $('#kickedKeg').prop('checked', true);
    }
    displayKegKickedAlert(keg.kickedReports.length);

    $('#kickedKeg').on('click', function() {
        var index = keg.kickedReports.indexOf(user.objectId);
        if (index < 0) {
            keg.kickedReports.push(user.objectId);
        }
        else {
            keg.kickedReports.splice(index, 1);
        }
        updateKickedKegReports(keg);
        displayKegKickedAlert(keg.kickedReports.length);
    });

    $('#request-beer').click(function(){
        var beerType = $('#beerType').val();
        var beerRequest = {
            name: beerType,
            user_id: user.objectId,
            votes: [user.objectId]
        };
        beerRequestResult = saveBeerRequest(beerRequest);
        displayBeerRequests();
    });

    $('.beer-vote').click(function(event){
        event.preventDefault();
        var beerRequestId = $(this).attr('beer-request');
        var voteCount = parseInt($(this).text().split('+')[1], 10);
        if ($(this).hasClass('btn-primary')){
            voteCount = voteCount - 1;
        }
        else
        {
            voteCount = voteCount + 1;
        }
        $(this).text('+' + voteCount.toString()).toggleClass('btn-primary').toggleClass('btn-default');
        toggleBeerRequestVoteForUser(beerRequestId, user.objectId);
    });

    $('.update-keg').click(function(event){
        event.preventDefault();
        var beerRequestId = $(this).attr('beer-request');
        updateBeerOnTap(beerRequestId);
    });
});

function getBeerOnTap() {
    var where = {
        order: '-createdAt',
        limit: 1
    };
    var results = apiRequest('/1/classes/Keg', where);
    return results.results[0];
}

function updateKickedKegReports(keg){
    apiRequest('/1/classes/Keg/'+ keg.objectId, {'kickedReports': keg.kickedReports}, 'PUT');
}

function updateBeerOnTap(beerRequestId){
    var request = apiRequest('/1/classes/BeerRequest/'+ beerRequestId);
    var newKeg = {
        beerName: request.name,
        kickedReports: []
    };
    apiRequest('/1/classes/Keg', newKeg, 'POST');
    displayBeerOnTap(newKeg);
    $('#kickedKeg').prop('checked', false);
    var beerRequests = getBeerRequests();
    for (var i = 0; i < beerRequests.length; i++){
        var currentRequest = beerRequests[i];
        setBeerRequestInactive(currentRequest.objectId);
    }
    displayBeerRequests();
}

function saveBeerRequest(beerRequest){
    var requestResults = apiRequest('/1/classes/BeerRequest', beerRequest, 'POST');
    return requestResults;
}

function getBeerRequests(){
    var where = {
        order: 'name',
        where: JSON.stringify({
            inactive: false
        })
    };
    var results = apiRequest('/1/classes/BeerRequest', where);
    for (var i = 0; i < results.results.length; i++){
        var request = results.results[i];
        results.results[i] = request;
    }
    return results.results;
}

function toggleBeerRequestVoteForUser(beerRequestId, userId){
    var request = apiRequest('/1/classes/BeerRequest/'+ beerRequestId);
    var index = request.votes.indexOf(userId);
    if (index < 0){
        request.votes.push(userId);
    }
    else
    {
        request.votes.splice(index, 1);
    }
    apiRequest('/1/classes/BeerRequest/'+ beerRequestId, {'votes': request.votes}, 'PUT');
}

function setBeerRequestInactive(beerRequestId){
    apiRequest('/1/classes/BeerRequest/'+ beerRequestId, {'inactive': true}, 'PUT');
}

function displayBeerRequests(){
    var user = getCurrentUser();
    var beerRequests = getBeerRequests();
    var $tbody = $("#beer-request-list tbody");
    $tbody.empty();
    for (var i = 0; i < beerRequests.length; i++){
        var request = beerRequests[i];
        var voteBtnClass = 'btn-default';
        if (request.votes.indexOf(user.objectId) >= 0){
            voteBtnClass = 'btn-primary';
        }
        var $row = $('<tr>');
        var $beerType = $('<td>').text(request.name);
        var $voteCount = $('<a beer-request="' + request.objectId + '" href="#" class="btn ' + voteBtnClass + ' beer-vote">').text('+' + request.votes.length.toString());
        var $updateKeg = $('<a beer-request="' + request.objectId + '" href="#" class="btn btn-danger admin update-keg">').text('Fill Keg');
        $voteCount = $('<td>').append($voteCount).append($updateKeg);
        $row.append($beerType).append($voteCount);
        $tbody.append($row);
    }
    if (user.admin){
        $('.admin').show();
    }
}

function displayBeerOnTap(keg){
    $('#beerOnTap').html('<h3>' + keg.beerName);
}

function displayKegKickedAlert(numberOfReports){
    var text = numberOfReports.toString();
    if (numberOfReports > 0){
        if (numberOfReports == 1){
            text = text + ' person';
        }
        else
        {
            text = text + ' people';
        }
        $('.kicked-alert').show();
    }
    else
    {
        text = text + ' people';
        $('.kicked-alert').hide();
    }
    $('.kicked-count').text(text);
}