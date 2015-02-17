function savePreferences() {
	console.log("save prefs");
    var user = Parse.User.current();
    var customPref = $('#customPrefs').val();
    var preferences = [parseInt($("input:radio[name ='preferences']:checked").attr('id'))];
    var restrictions = parseInt($("input:checkbox[name ='restrictions']:checked").attr('id'));
	console.log(user);
    if (restrictions) {
        preferences.push(restrictions);
    }
	
	user.setPreferences(preferences);
	user.setPreferenceNote(customPref);
	user.save(null, {
		success: function(user) {
			$('#savePrefs').addClass('btn-danger');
			$('#savePrefs').text('Preferences saved!');
		},
		error: function(user, error) {
			console.log(error.message);
		}
	});
}

$(document).ready(function () {
    var user = Parse.User.current();
    var preferences = user.getPreferences();
    if (preferences) {
        $('#' + preferences).prop('checked', 'yes');
        if (preferences) {
            $('#' + preferences).prop('checked', 'yes');
        }
    }

    if (user.getPreferenceNote()) {
        $('#customPrefs').val(user.getPreferenceNote());
    }
    
    $('#savePrefs').on('click', savePreferences);
});
