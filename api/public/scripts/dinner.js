$(document).ready(function() {
	var user = getCurrentUser();
	updateLoginInfo(user);
	if (user) {
		var dinnerRequest = apiRequest('/1/classes/Dinner', {where: {'user_id' : user.objectId}}, 'GET');		
	}
	else {
		return;
	}
	var userDinners = dinnerRequest.results;
	var yesterday = new Date();
	yesterday.setUTCHours(0, 0, 0, 0);	
	var dinnerReqToday;
	for (var i = 0; i < userDinners.length; i++) {
		var orderDateISO = userDinners[i].order_date.iso;
	    var date = new Date(orderDateISO);
	    if (date > yesterday) {
	    	dinnerReqToday = userDinners[i];
			$('#order-dinner').addClass('btn-danger');
			$('#order-dinner').text('Dinner Ordered!');
			var prefs = user.preferences;
			for (pref in prefs) {
				$('#'+prefs[pref]).attr('checked', true);
			}	    	
	    }  
	}

	$('#order-dinner').on('click', function() {
		toggleDinner(user, dinnerReqToday);
		$(".cat-image").show();
		updateDinnerTable();
	});

	updateDinnerTable();
});

function updateDinnerTable() {
	var dinners = getOrderedDinners();
	$tbody = $('#dinner-request-list tbody');
	$tbody.empty();

	for (var i = 0; i < dinners.length; i++) {
        var request = dinners[i];
        var currentUser = findUser(request.user_id);
        var $row = $('<tr>');
        var $name = $('<td>').html("<img src='" + currentUser.picture + "'> " + currentUser.name);
        var $notes = $('<td>');        
        var pref = currentUser.preferences;
        var $p = $('<td>');
        if (pref) {
	        for (var j = 0; j < pref.length; j++) {
	        	if (pref[j] === 0) {
	        		$p.append('<i class="icon-omnivore" alt="Omnivore" title="Omnivore" data-toggle="tooltip" data-placement="bottom"></i>&nbsp;');
	        	}
				else if (pref[j] === 1) {
	        		$p.append('<i class="icon-vegetarian" alt="Vegetarian" title="Vegetarian" data-toggle="tooltip" data-placement="bottom"></i>&nbsp;');
	        	}        	
	        	else if (pref[j] === 2) {
	        		$p.append('<i class="icon-vegan" alt="Vegan" title="Vegan" data-toggle="tooltip" data-placement="bottom"></i>&nbsp;');
	        	}

	        	if (pref[j] === 3) {
	        		$p.append('<i class="icon-gluten" alt="No Gluten" title="No Gluten" data-toggle="tooltip" data-placement="bottom"></i>&nbsp;');
	        	}
	        }	        
        }
        if (currentUser.special_request) {
        	$notes.append(currentUser.special_request);
        }        
        $row.append($name).append($p).append($notes);
        $tbody.append($row);
	  	$('[data-toggle="tooltip"]').tooltip()
	}	
}

function getOrderedDinners() {
	var yesterday = new Date();
	yesterday.setUTCHours(0, 0, 0, 0);
	var dinnerRequest = apiRequest('/1/classes/Dinner', {}, 'GET');
	var dinners = dinnerRequest.results;
	var y = [];
	for (var i = 0; i < dinners.length; i++) { 
		var orderDateISO = dinners[i].order_date.iso;
	    var date = new Date(orderDateISO);
	    if (date > yesterday) {
	    	y.push(dinners[i]);
	    }  
	}			
	return y;
}

function toggleDinner(user, dinnerReqToday) {
	if ($('#order-dinner').hasClass('btn-danger') && dinnerReqToday) {
		var removed = apiRequest('/1/classes/Dinner/' + dinnerReqToday.objectId , {}, 'DELETE');		
		$('#order-dinner').removeClass('btn-danger');
		$('#order-dinner').text('Order Dinner Tonight!');		
	}
	else {
		var preferences = [parseInt($("input:radio[name ='preferences']:checked").attr('id'))];
		var restrictions = parseInt($("input:checkbox[name ='restrictions']:checked").attr('id'));
		var today = new Date();
		today.setUTCHours(24, 0, 0, 0);
		today.toISOString();
		console.log(today);
		if (restrictions) {
			preferences.push(restrictions);
		}
		var data = {
			'picture': user.picture, 
			'name': user.name, 
			'user_id' : user.objectId, 
			'preferences' : preferences,
			'order_date': {
				'__type': 'Date',
				'iso': today
			}
		};
		var dinnerRequest = apiRequest('/1/classes/Dinner', data ,'POST');
		$('#order-dinner').addClass('btn-danger');
		$('#order-dinner').text('Dinner Ordered!');
	}
}

function countdown() {
	var now = new Date();
	var hoursLeft = 15-now.getHours();
	if (hoursLeft < 0) {
		hoursLeft = 16-now.getHours();		
		var minutesleft = now.getMinutes();
		var secondsleft = now.getSeconds();		
	}
	else {
		var minutesleft = 59-now.getMinutes();
		var secondsleft = 59-now.getSeconds();		
	}
		
	//format 0 prefixes
	if(minutesleft<10) minutesleft = "0"+minutesleft;
	if(secondsleft<10) secondsleft = "0"+secondsleft;
	var label = "<span class='dinner-label'>Time left to order dinner:</span>";
	$('.countdown').html(label + 
		"<span class='time'>" + hoursLeft+":"+minutesleft+":"+secondsleft + "</span>");
}

countdown();
setInterval(countdown, 1000);
