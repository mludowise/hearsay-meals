$(document).ready(function() {
    $('.loading').show();
    var user = getCurrentUser();
    updateLoginInfo(user);
    displayBeerRequests();

    var keg = getBeerOnTap();
    displayBeerOnTap(keg);
    if (keg.kickedReports.indexOf(user.objectId) >= 0) {
        $('#kicked-keg').removeClass('btn-danger').addClass('btn-primary').text('Unreport Keg Kicked');
    }
    displayKegKickedAlert(keg.kickedReports.length);

    $('#kicked-keg').on('click', function() {
        var index = keg.kickedReports.indexOf(user.objectId);
        if (index < 0) {
            keg.kickedReports.push(user.objectId);
            $(this).text('Unreport Keg Kicked');
        }
        else {
            keg.kickedReports.splice(index, 1);
            $(this).text('Report Keg Kicked');
        }
        $(this).toggleClass('btn-danger').toggleClass('btn-primary');
        updateKickedKegReports(keg);
        displayKegKickedAlert(keg.kickedReports.length);
    });

    $('#request-beer').click(function(){
        var beerType = $('#beer-type').val();
        $('#beer-type').val('');
        var beerRequest = {
            name: beerType,
            user_id: user.objectId,
            votes: [user.objectId]
        };
        beerRequestResult = saveBeerRequest(beerRequest);
        displayBeerRequests();
    });

    $('#add-new-keg').click(function(event){
        var beerType = $('#update-keg').val();
        $('#update-keg').val('');
        updateBeerOnTap(beerType);
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

    $('#beer-request-list').on('click', '.update-keg', function(event){
        event.preventDefault();
        if (!currentUserIsAdmin()){
            return;
        }
        var beerRequestId = $(this).attr('beer-request');
        var request = apiRequest('/1/classes/BeerRequest/' + beerRequestId);
        updateBeerOnTap(request.name);
        deleteBeerRequest(beerRequestId);
        displayBeerRequests();
    });

    $('#beer-request-list').on('click', '.dismiss-request', function(event){
        event.preventDefault();
        var beerRequestId = $(this).attr('beer-request');
        deleteBeerRequest(beerRequestId);
        displayBeerRequests();
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

function updateBeerOnTap(beerName){
    $('#beer-on-tap').hide();
    $('.loading').show();
    var newKeg = {
        beerName: beerName,
        kickedReports: []
    };
    results = apiRequest('/1/classes/Keg', newKeg, 'POST');
    $.extend(newKeg, results);
    displayBeerOnTap(newKeg);
    $('#kicked-keg').addClass('btn-danger').removeClass('btn-primary').text('Report Keg Kicked');
    displayKegKickedAlert(0);
}

function saveBeerRequest(beerRequest){
    var requestResults = apiRequest('/1/classes/BeerRequest', beerRequest, 'POST');
    return requestResults;
}

function getBeerRequests(){
    var where = {
        order: 'name'
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

function deleteBeerRequest(beerRequestId){
    if (currentUserIsAdmin()){
        apiRequest('/1/classes/BeerRequest/'+ beerRequestId, null, 'DELETE');
    }
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
        var $beerType = $('<td class="beer-request-name">').text(request.name);
        var $voteCount = $('<a beer-request="' + request.objectId + '" href="#" class="btn ' + voteBtnClass + ' beer-vote">').text('+' + request.votes.length.toString());
        $voteCount = $('<td>').append($voteCount);
        $row.append($beerType).append($voteCount);
        if (currentUserIsAdmin()){
            var $admin = $('<td>');
            var $updateKeg = $('<a beer-request="' + request.objectId + '" href="#" class="btn btn-default admin update-keg">').text('Fill Keg');
            var $dismissRequest = $('<a beer-request="' + request.objectId + '" href="#" class="btn btn-danger admin dismiss-request">').text('Delete');
            $admin.append($updateKeg).append($dismissRequest);
            $row.append($admin);
        }
        $tbody.append($row);
    }
    showAdmin();
}

function displayBeerOnTap(keg){
    var $beerOnTap = $('#beer-on-tap');
    $beerOnTap.empty();
    var $kegName = $('<h1>').text(keg.beerName);
    var kegFillDate = new Date(keg.createdAt);
    var today = new Date();
    var differenceInDays = Math.floor((today - kegFillDate)/(1000*60*60*24));
    var filledText = 'Filled';
    if (differenceInDays === 0){
        filledText += ' today.';
    }
    else if (differenceInDays == 1){
        filledText += ' yesterday.';
    }
    else {
        filledText += ' ' + differenceInDays.toString() + ' days ago.';
    }
    var $fillDate = $('<div>').text(filledText);
    $('.loading').hide();
    $beerOnTap.append($kegName).append($fillDate).show();
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