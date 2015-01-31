$(document).ready(function() {
    $('#order-dinner').on('click', function() {
        toggleDinner();
    });

    updateDinnerTable();

    countdown();
    setInterval(countdown, 1000);
});

function getOrderDateISO(){
    var orderDate = new Date();
    orderDate.setHours(16, 0, 0, 0);
    return orderDate.toISOString();
}

function updateOrderButton(ordered) {
	$('#order-dinner').attr("ordered", ordered);
	
	if (ordered) {
		$('#order-dinner').addClass('btn-danger');
		$('#order-dinner').text('Cancel Dinner Order');
		$('#special-notes').hide();
	} else {
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
	});
}

function toggleDinner() {
	var ordered = $('#order-dinner').attr("ordered");
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
		});
	} else {
		Parse.Cloud.run("dinnerCancelOrder").then(function(order) {
			updateOrderButton(false);
			$(".cat-image").hide();
			updateDinnerTable();
		});
	}
}

function countdown() {
    var now = new Date();
    var hoursLeft = 15-now.getHours();
    var secondsLeft;
    var minutesLeft;
    var prefix = "";
    if (hoursLeft < 0) {
        hoursLeft = 16-now.getHours();
        minutesLeft = now.getMinutes();
        secondsLeft = now.getSeconds();
        if (hoursLeft === 0) {
            prefix = "-";
        }
    }
    else {
        minutesLeft = 59-now.getMinutes();
        secondsLeft = 59-now.getSeconds();
        prefix = "";        
    }
    
    //format 0 prefixes
    if(minutesLeft<10) minutesLeft = "0"+minutesLeft;
    if(secondsLeft<10) secondsLeft = "0"+secondsLeft;
    $('.countdown .time').html(prefix + hoursLeft+":"+minutesLeft+":"+secondsLeft);
}
