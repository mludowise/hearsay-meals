var currentKeg = null;

$(document).ready(function() {
    var user = Parse.User.current();
    updateLoginInfo(user);
	    
	displayKeg();
    displayBeerRequests();
    
    $('#kicked-keg').on('click', function() {
    	toggleReportKegKicked();
    });

    $('#request-beer').click(function(){
    	addBeerRequest();
    });

    $('#add-new-keg').click(function(event){
    	addNewKeg();
    });

    $('#beer-request-list').on('click', '.update-keg', function(event){
        event.preventDefault();
		var beerRequestId = $(this).attr('beer-request');
    	addNewKegFromRequest(beerRequestId);
    });

    $('#beer-request-list').on('click', '.dismiss-request', function(event){
        event.preventDefault();
        var beerRequestId = $(this).attr('beer-request');
        deleteBeerRequest(beerRequestId);
    });
    
    $('#beer-request-list').on('click', '.beer-vote', function(event){
		event.preventDefault();
		var beerRequestId = $(this).attr('beer-request');
		console.log(beerRequestId);
		toggleBeerRequestVote(beerRequestId);
	});
});

function toggleBeerRequestVote(beerRequestId){
	var $voteButton = $('#beerRequestRow_' + beerRequestId + ' .beer-vote');
	console.log($voteButton);
	var voted = $voteButton.hasClass('voted');
	console.log(voted);
	var promise;
	if (!voted) {
		console.log("vote");
		promise = Parse.Cloud.run('beerVoteForRequest', {id: beerRequestId});
	} else {
		console.log("unvote");
		promise = Parse.Cloud.run('beerUnvoteForRequest', {id: beerRequestId});
	}
	var voteCount = 0;
	promise.then(function(votes) {
		voteCount = votes.length;
		$voteButton.text('+' + voteCount.toString()).toggleClass('btn-primary').toggleClass('btn-default').toggleClass('voted');
	});
}

function getBeerOnTap() {
    var where = {
        order: '-createdAt',
        limit: 1
    };
    var results = apiRequest('/1/classes/Keg', where);
    return results.results[0];
}

function toggleReportKegKicked() {
	var userReportedKicked = containsCurrentUser(currentKeg.kickedReports)
	var promise;
	if (!userReportedKicked) {
		promise = Parse.Cloud.run("beerReportKicked", {id: currentKeg.id});
	} else {
		promise = Parse.Cloud.run("beerUnreportKicked", {id: currentKeg.id});
	}
	promise.then(function(kickedReports) {
		currentKeg.kickedReports = kickedReports;
		displayKegKickedAlert(kickedReports);
	});
}

function updateBeerOnTap(beerName) {
	displayKegLoading();
    var newKeg = {
        beerName: beerName,
        kickedReports: []
    };
    results = apiRequest('/1/classes/Keg', newKeg, 'POST');
    $.extend(newKeg, results);
    displayKeg(newKeg);
    displayKegKickedAlert(null);
}

function addNewKeg() {
	displayKegLoading();
	
	var beerType = $('#update-keg').val();
	$('#update-keg').val('');
	Parse.Cloud.run("beerFillKeg", {name: beerType}).then(function() {
		displayKegInfo(beerType, new Date());
		displayKegKickedAlert([]);
	});
}

function addNewKegFromRequest(beerRequestId) {
	displayKegLoading();
	
	Parse.Cloud.run("beerFillKegFromRequest", {id: beerRequestId}).then(function(response) {
		displayKegInfo(response.name, new Date());
		displayKegKickedAlert([]);
		$('#beerRequestRow_' + beerRequestId).detach();
		displayBeerRequests();
	});
}

function saveBeerRequest(beerRequest){
    var requestResults = apiRequest('/1/classes/BeerRequest', beerRequest, 'POST');
    return requestResults;
}

function addBeerRequest(beerRequest) {
	var beerType = $('#beer-type').val();
	$('#beer-type').val('');
	
	Parse.Cloud.run("beerAddRequest", {name: beerType}).then(function(response) {
		displayBeerRequests();
	},
	function(error) {
		alert(error.message);
	});
}

// function toggleBeerRequestVote(beerRequestId){ 
// 	var userId = Parse.User.current().id;
//     var request = apiRequest('/1/classes/BeerRequest/'+ beerRequestId);
//     var index = request.votes.indexOf(userId);
//     if (index < 0){
//         request.votes.push(userId);
//     } 
//     else
//     {
//         request.votes.splice(index, 1);
//     }
//     apiRequest('/1/classes/BeerRequest/'+ beerRequestId, {'votes': request.votes}, 'PUT');
// }

function deleteBeerRequest(beerRequestId){
	Parse.Cloud.run("beerRemoveRequest", {id: beerRequestId}).then(function() {
        displayBeerRequests();
	},
	function(error) {
        displayBeerRequests();
	});
// 	
//     if (currentUserIsAdmin()){
//         apiRequest('/1/classes/BeerRequest/'+ beerRequestId, null, 'DELETE');
//         displayBeerRequests();
//     }
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
			var $row = $('<tr id="beerRequestRow_' + request.id + '">');
			var $beerType = $('<td class="beer-request-name">').text(request.name);
			var $voteButton = $('<button beer-request="' + request.id + '" class="btn beer-vote">').text('+' + request.votes.length.toString());
//			$voteButton.click(toggleBeerRequestVote);
			
			var votes = request.votes
			if (containsCurrentUser(votes)){
				$voteButton.addClass('btn-primary')
				$voteButton.addClass('voted');
			} else {
				$voteButton.addClass('btn-default')
			}
			
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
		
// 		$('.beer-vote').click(function(event) {
// 			event.preventDefault();
// 			var beerRequestId = $(this).attr('beer-request');
// 			console.log(beerRequestId);
// 			toggleBeerRequestVote(beerRequestId);
// 		});
    });
}

function displayKegLoading() {
	$('#ontap-beer').html('&nbsp;');
	$('#ontap-filldate').html('&nbsp;');
    $('.loading').show();
}

function displayKegInfo(beerName, date) {
    var filledText;
    
	if (!date) {
		filledText += 'Filled today.';
	} else {
		var kegFillDate = new Date(date);
		var today = new Date();
		
		// Set time of day to midnight
		kegFillDate.setHours(0, 0, 0, 0);
		today.setHours(0, 0, 0, 0);
	
		var differenceInDays = Math.floor((today - kegFillDate)/(1000*60*60*24));
	
		if (differenceInDays === 0){
			filledText = 'Filled today.';
		}
		else if (differenceInDays == 1){
			filledText = 'Filled yesterday.';
		}
		else {
			filledText = 'Filled ' + differenceInDays + ' days ago.';
		}
	}
	
    // Show keg info and and stop loading
	$('#ontap-beer').text(beerName);
    $('#ontap-filldate').text(filledText);
    $('.loading').hide();
}

function displayKeg() {
	displayKegLoading();
	Parse.Cloud.run("beerOnTap").then(function(keg) {
		currentKeg = keg;
		displayKegInfo(keg.beer.name, keg.filled);
		displayKegKickedAlert(keg.kickedReports);
	})
}

function displayKegKickedAlert(kickedReports){
	var numberOfReports = 0;
	if (kickedReports) {
		numberOfReports = kickedReports.length;
		
		if (containsCurrentUser(kickedReports)) {
			$('#kicked-keg').removeClass('btn-danger').addClass('btn-primary').text('Unreport Keg Kicked');
		} else {
			$('#kicked-keg').addClass('btn-danger').removeClass('btn-primary').text('Report Keg Kicked');
		}
	}
			
    var text;
    if (numberOfReports > 0){
        if (numberOfReports == 1){
            text = numberOfReports + ' person';
        }
        else
        {
            text = numberOfReports + ' people';
        }
        $('.kicked-alert').show();
    }
    else
    {
        text = numberOfReports + ' people';
        $('.kicked-alert').hide();
    }
    $('.kicked-count').text(text);
}