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
