$(document).ready(function() {
	var user = getCurrentUser();
	updateLoginInfo(user);	
	if (user.preferences) {
		$('#' + user.preferences[0]).prop('checked', 'yes');
		if (user.preferences[1]) {
			$('#' + user.preferences[1]).prop('checked', 'yes');
		}
	}
    
    if (user.preference_note) {
    $('#customPrefs').val(user.preference_note);
    }
    
   // console.log(user);
});

$('#savePrefs').on('click', savePreferences);

function savePreferences(){
	var user = getCurrentUser();
    var customPref = $('#customPrefs').val();
	var preferences = [parseInt($("input:radio[name ='preferences']:checked").attr('id'))];
	var restrictions = parseInt($("input:checkbox[name ='restrictions']:checked").attr('id'));
    
	if (restrictions) {
		preferences.push(restrictions);
	}
    
	var dinnerRequest = apiRequest('/1/users/'+ user.objectId, {'preferences' : preferences, 'preference_note' : customPref},'PUT');
	$('#savePrefs').addClass('btn-danger');
	$('#savePrefs').text('Preferences saved!');
}