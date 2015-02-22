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

function fetchPreferences() {
    var user = Parse.User.current();
    user.fetch().then(function(user) { // Refresh user in case preferences were edited in a different browser or mobile
		var preferences = user.getPreferences();
		if (preferences) {
			for (var i in preferences) {
				console.log(preferences[i]);
				$('#' + preferences[i]).prop('checked', 'yes');
			}
		}
    });

    if (user.getPreferenceNote()) {
        $('#customPrefs').val(user.getPreferenceNote());
    }
}

function hidePreferencesHelpTip() {
	if (typeof(Storage) !== "undefined") {
		localStorage.visitedPreferences = true
	}
}

$(document).ready(function () {
	hidePreferencesHelpTip()
    fetchPreferences()
    $('#savePrefs').on('click', savePreferences);
});
