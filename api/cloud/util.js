exports.find = function(objects, param, value) {
	for (var i in objects) {
		var object = objects[i];
		if (object.get(param) == value) {
			return object;
		}
	}
	return null;
}

exports.userInfo = function(user, includePrefs) {
	var user = {
		id: user.id,
		name: user.get("name"),
		picture: user.get("picture"),
	};
	if (includePrefs) {
		user.preferences = user.get("preferences");
		user.preferenceNote = user.get("preference_note");
	}
	return user;
}