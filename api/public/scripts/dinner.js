$(document).ready(function() {
    var user = getCurrentUser();
    updateLoginInfo(user);

    var now = new Date();
    if (user) {
        var whereClause = {
            'user_id' : user.objectId,
            'order_date': {
                '__type': 'Date',
                'iso': getOrderDateISO()
            }
        };
        var dinnerRequest = apiRequest('/1/classes/Dinner', {where: whereClause}, 'GET');
        if (dinnerRequest.results.length > 0){
            $('#order-dinner').addClass('btn-danger');
            $('#order-dinner').text('Cancel Dinner Order');
        }
    }

    $('#order-dinner').on('click', function() {
        toggleDinner(user);
        $(".cat-image").show();
        updateDinnerTable();
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
        if (request.special_request) {
            $notes.append(request.special_request);
        }
        $row.append($name).append($p).append($notes);
        $tbody.append($row);
        $('[data-toggle="tooltip"]').tooltip();
    }
}

function getOrderedDinners() {
    var whereClause = {
        'order_date': {
            '__type': 'Date',
            'iso': getOrderDateISO()
        }
    };
    var dinnerRequest = apiRequest('/1/classes/Dinner', {where: whereClause, order: 'createdAt'}, 'GET');
    return dinnerRequest.results;
}

function toggleDinner(user) {
    var whereClause = {
        'user_id' : user.objectId,
        'order_date': {
            '__type': 'Date',
            'iso': getOrderDateISO()
        }
    };
    var dinnerRequest = apiRequest('/1/classes/Dinner', {where: whereClause}, 'GET');
    if (dinnerRequest.results.length > 0) {
        apiRequest('/1/classes/Dinner/' + dinnerRequest.results[0].objectId , {}, 'DELETE');
        $('#order-dinner').removeClass('btn-danger');
        $('#order-dinner').text('Order Dinner Tonight');
    }
    else {
        var specialRequest = $('#special-notes').val();
        $('#special-notes').val('');
        var data = {
            'picture': user.picture,
            'name': user.name,
            'user_id' : user.objectId,
            'special_request' : specialRequest,
            'order_date': {
                '__type': 'Date',
                'iso': getOrderDateISO()
            }
        };
        apiRequest('/1/classes/Dinner', data ,'POST');
        $('#order-dinner').addClass('btn-danger');
        $('#order-dinner').text('Cancel Dinner Order');
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
