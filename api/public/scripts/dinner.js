$(document).ready(function() {
	if (localStorage.getItem('email')) {
		var email = localStorage.getItem('email');
		if (localStorage.getItem('userCreated')) {
			user = getCurrentUser();
		}
	}
	$('#order-dinner').on('click', function() {

	});
});

function onSignInCallback(response) {
	console.log(response);
	key = "AIzaSyAW7z4SEmncGb9ElHfWlCOn6gejEPm0vHo";
	if (response.status.signed_in) {
		$('#gConnect').hide();
		gapi.client.load('oauth2', 'v2', function() {
		  gapi.client.oauth2.userinfo.get().execute(function(resp) {
		  	if (resp.hd !== 'hearsaycorp.com') {
		  		alert('You must have a Hearsay email to use this app');
		  		return;
		  	}
		    localStorage.setItem('email', resp.email);
		    localStorage.setItem('name', resp.name);
		    var data = {
		    	email : resp.email,
		    	password : 'password',
		    	username : resp.email,
		    	name : resp.name,
		    	picture : resp.picture
		    };
		    var newUser = apiRequest('/1/users', data, 'POST');
		    console.log(newUser);
		  });
		});
	}
}

function countdown() {
	var now = new Date();
	var hoursLeft = 15 - now.getHours();
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
