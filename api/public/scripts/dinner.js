$(document).ready(function() {
	var user = getCurrentUser();
	var dinnerRequest = apiRequest('/1/classes/Dinner', {where: {'user_id' : user.objectId}}, 'GET');	
	if (dinnerRequest.results[0]) {
		$('#order-dinner').addClass('btn-danger');
		$('#order-dinner').text('Dinner Ordered!');
		var prefs = dinnerRequest.results[0].preferences;
		for (pref in prefs) {
			$('#'+prefs[pref]).attr('checked', true);
		}
	}
	$('#order-dinner').on('click', function() {
		toggleDinner(user);
	});

	var dinners = getOrderedDinners();

	for (var i = 0; i < dinners.length; i++) {
		console.log(dinners[i]);
	}

});

function getOrderedDinners() {
	var yesterday = new Date();
	yesterday.setUTCHours(0, 0, 0, 0);
	yesterday = yesterday.toISOString();
	var today = new Date();
	today.setUTCHours(24, 0, 0, 0);
	today = today.toISOString();
	var data =  {where: {'createdAt' : {"$gte": { "__type": "Date", "iso": yesterday }, "$lte": { "__type": "Date", "iso": today}}}};
	data = JSON.stringify(data);
	var dinnerRequest = apiRequest('/1/classes/Dinner', data, 'GET');		
	return dinnerRequest.results;
}

function toggleDinner(user) {
	if ($('#order-dinner').hasClass('btn-danger')) {
		var dinnerRequest = apiRequest('/1/classes/Dinner', {'user_id' : user.objectId}, 'GET');
		var removed = apiRequest('/1/classes/Dinner/' + dinnerRequest.results[0].objectId ,{}, 'DELETE');		
		$('#order-dinner').removeClass('btn-danger');
		$('#order-dinner').text('Order Dinner Tonight!');		
	}
	else {
		var preferences = [parseInt($("input:radio[name ='preferences']:checked").attr('id'))];
		var restrictions = parseInt($("input:checkbox[name ='restrictions']:checked").attr('id'));
		if (restrictions) {
			preferences.push(restrictions);
		}
		var dinnerRequest = apiRequest('/1/classes/Dinner', {'picture': user.picture, 'name': user.name, 'user_id' : user.objectId, 'preferences' : preferences} ,'POST');
		$('#order-dinner').addClass('btn-danger');
		$('#order-dinner').text('Dinner Ordered!');
	}
}

function countdown() {
	var now = new Date();
	var hoursLeft = 15-now.getHours();
	var minutesleft = 59-now.getMinutes();
	var secondsleft = 59-now.getSeconds();	
	//format 0 prefixes
	if(minutesleft<10) minutesleft = "0"+minutesleft;
	if(secondsleft<10) secondsleft = "0"+secondsleft;
	var label = "<span class='dinner-label'>Time left to order dinner:</span>";
	$('.countdown').html(label + 
		"<span class='time'>" + hoursLeft+":"+minutesleft+":"+secondsleft + "</span>");
}

countdown();
setInterval(countdown, 1000);
