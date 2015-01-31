$(document).ready(function() {
    var user = Parse.User.current();
    updateLoginInfo(user);
    
	displayKegLoading();
	var keg = getBeerOnTap(); 
    displayKegInfo(keg.beerName, new Date(keg.createdAt));
    if (keg.kickedReports.indexOf(Parse.User.current().id) >= 0) {
        $('#kicked-keg').removeClass('btn-danger').addClass('btn-primary').text('Unreport Keg Kicked');
    }
    displayKegKickedAlert(keg.kickedReports.length);

    displayBeerRequests();
    
    $('#kicked-keg').on('click', function() {
    	toggleReportKegKicked(keg);
    });

    $('#request-beer').click(function(){
        var beerType = $('#beer-type').val();
        $('#beer-type').val('');
        var beerRequest = {
            name: beerType,
            user_id: user.id,
            votes: [user.id]
        };
        beerRequestResult = saveBeerRequest(beerRequest);
        displayBeerRequests();
    });

    $('#add-new-keg').click(function(event){
        var beerType = $('#update-keg').val();
        $('#update-keg').val('');
        updateBeerOnTap(beerType);
    });

    $('.beer-vote').click(voteForBeer);

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

function voteForBeer(event){
	event.preventDefault();
	var beerRequestId = $(this).attr('beer-request');
	var voteCount = parseInt($(this).text().split('+')[1], 10);
	if ($(this).hasClass('btn-primary')){
		voteCount = voteCount - 1;
	} else {
		voteCount = voteCount + 1;
	}
	$(this).text('+' + voteCount.toString()).toggleClass('btn-primary').toggleClass('btn-default');
	toggleBeerRequestVote(beerRequestId);
}

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

function toggleReportKegKicked(keg) {
	var userId = Parse.User.current().id;
	var index = keg.kickedReports.indexOf(userId);
	if (index < 0) {
		keg.kickedReports.push(userId);
		$('#kicked-keg').text('Unreport Keg Kicked');
	}
	else {
		keg.kickedReports.splice(index, 1);
		$('#kicked-keg').text('Report Keg Kicked');
	}
	$('#kicked-keg').toggleClass('btn-danger').toggleClass('btn-primary');
	updateKickedKegReports(keg);
	displayKegKickedAlert(keg.kickedReports.length);
}

function updateBeerOnTap(beerName){
	displayKegLoading();
    var newKeg = {
        beerName: beerName,
        kickedReports: []
    };
    results = apiRequest('/1/classes/Keg', newKeg, 'POST');
    $.extend(newKeg, results);
    displayKeg(newKeg);
    $('#kicked-keg').addClass('btn-danger').removeClass('btn-primary').text('Report Keg Kicked');
    displayKegKickedAlert(0);
}

function saveBeerRequest(beerRequest){
    var requestResults = apiRequest('/1/classes/BeerRequest', beerRequest, 'POST');
    return requestResults;
}

function toggleBeerRequestVote(beerRequestId){
	var userId = Parse.User.current().id
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

function containsCurrentUser(jsonUsers) {
	for (var i in jsonUsers) {
		var jsonUser = jsonUsers[i];
		if (jsonUser.id == Parse.User.current().id) {
			return true;
		}
	}
	return false;
}

function displayBeerRequests() {
    var user = Parse.User.current()
    Parse.Cloud.run("beerGetRequests").then(function(beerRequests) {
		var $tbody = $("#beer-request-list tbody");
		$tbody.empty();
		for (var i in beerRequests){
			var request = beerRequests[i];
			var voteBtnClass = 'btn-default';
			var votes = request.votes
			if (containsCurrentUser(votes)){
				voteBtnClass = 'btn-primary';
			}
			var $row = $('<tr>');
			var $beerType = $('<td class="beer-request-name">').text(request.name);
			var $voteButton = $('<button beer-request="' + request.id + '" class="btn ' + voteBtnClass + ' beer-vote">').text('+' + request.votes.length.toString());
			$voteButton.click(voteForBeer);
			var $voteCount = $('<td>').append($voteButton);
			$row.append($beerType).append($voteCount);
			if (currentUserIsAdmin()){
				var $admin = $('<td>');
				var $updateKeg = $('<a beer-request="' + request.id + '" href="#" class="btn btn-default admin update-keg">').text('Fill Keg');
				var $dismissRequest = $('<a beer-request="' + request.id + '" href="#" class="btn btn-danger admin dismiss-request">').text('Delete');
				$admin.append($updateKeg).append($dismissRequest);
				$row.append($admin);
			}
			$tbody.append($row);
		}
    });
}

function displayKegLoading() {
    $('#beer-on-tap').hide();
    $('.loading').show();
}

function displayKegInfo(beerName, kegFillDate) {
	if (!kegFillDate) {
		kegFillDate = new Date();
	}
    var $kegName = $('#ontap-beer').text(beerName);
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
    var $fillDate = $('#ontap-filldate').text(filledText);
    $('.loading').hide();
    $('#beer-on-tap').show();
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