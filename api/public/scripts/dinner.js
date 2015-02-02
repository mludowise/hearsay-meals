var orderDeadline = null;

$(document).ready(function() {
    $('#order-dinner').on('click', function() {
        toggleDinner();
    });

    updateDinnerTable();
	getDinnerConfig();
});

function getDinnerConfig() {
	Parse.Cloud.run("dinnerGetConfigs").then(function(configs) {
		orderDeadline = configs.orderDeadline;
		countdown();
		setInterval(countdown, 1000);
	}, function(error) {
		console.error(error);
	});
}

function updateOrderButton(ordered) {
	if (ordered) {
		$('#order-dinner').addClass('ordered');
		$('#order-dinner').addClass('btn-danger');
		$('#order-dinner').text('Cancel Dinner Order');
		$('#special-notes').hide();
	} else {
		$('#order-dinner').removeClass('ordered');
		$('#order-dinner').removeClass('btn-danger');
		$('#order-dinner').text('Order Dinner Tonight');
		$('#special-notes').show();
	}
}

function updateDinnerTable() {
	Parse.Cloud.run("dinnerGetOrders").then(function(dinners) {
		$tbody = $('#dinner-request-list tbody');
		$tbody.empty();

		for (var i = 0; i < dinners.length; i++) {
			var request = dinners[i];
			var user = request.user;
			if (user.id == Parse.User.current().id) { // Current user has ordered
				updateOrderButton(true);
			}
			
			var $row = $('<tr>');
			var $name = $('<td>').html("<img src='" + user.picture + "'> " + user.name);
			var $notes = $('<td>');
			var pref = user.preferences;
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
			if (request.specialRequest) {
				$notes.append(request.specialRequest);
			}
			$row.append($name).append($p).append($notes);
			$tbody.append($row);
			$('[data-toggle="tooltip"]').tooltip();
		}
	}, function(error) {
		console.error(error);
	});
}

function toggleDinner() {
	var ordered = $('#order-dinner').hasClass('ordered');
	if (!ordered) {
        var params = null;
        var specialRequest = $('#special-notes').val();
        if (specialRequest != '') {
        	params = {
        		specialRequest: specialRequest
        	}
        }
        
		Parse.Cloud.run("dinnerMakeOrder", params).then(function(order) {
			$('#special-notes').val('');
			updateOrderButton(true);
			$(".cat-image").show();
			updateDinnerTable();
		}, function(error) {
			console.error(error);
		});
	} else {
		Parse.Cloud.run("dinnerCancelOrder").then(function(order) {
			updateOrderButton(false);
			$(".cat-image").hide();
			updateDinnerTable();
		}, function(error) {
			console.error(error);
		});
	}
}

function countdown() {
    var now = moment().tz(
    	orderDeadline.timeZone
    );
    
    var deadlineMinutes = orderDeadline.time.hours * 60 + orderDeadline.time.minutes;
    var totalMinutesLeft = deadlineMinutes - now.hours() * 60 - now.minutes();
    
    var hoursLeft = Math.floor(totalMinutesLeft / 60);
    var minutesLeft, secondsLeft;
    var prefix = "";
    if (totalMinutesLeft < 0) {
    	hoursLeft += 1;
	    minutesLeft = (60 - totalMinutesLeft) % 60;
    	secondsLeft = now.seconds();
    	if (hoursLeft == 0) {
    		prefix = "-";
    	}
    } else {
    	minutesLeft = totalMinutesLeft % 60 - 1;
    	secondsLeft = 59 - now.seconds();
    }
    
    //format 0 prefixes
    if(minutesLeft<10) minutesLeft = "0"+minutesLeft;
    if(secondsLeft<10) secondsLeft = "0"+secondsLeft;
    $('.countdown .time').html(prefix + hoursLeft+":"+minutesLeft+":"+secondsLeft);
    
    if (totalMinutesLeft <= 15) {
    	$('.countdown .time').addClass('text-danger');
    } else {
    	$('.countdown .time').removeClass('text-danger');
    }
}
