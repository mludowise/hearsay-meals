var restrictedAcl = new Parse.ACL();
restrictedAcl.setPublicReadAccess(false);
restrictedAcl.setPublicWriteAccess(false);

exports.isUserAdmin = function(user) {
	return user.get("admin") == true;
}

exports.restrictedACL = function() {
	return restrictedAcl;
}

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
	var result = {
		id: user.id,
		name: user.get("name"),
		picture: user.get("picture"),
	};
	if (includePrefs) {
		result.preferences = user.get("preferences");
		result.preferenceNote = user.get("preference_note");
	}
	return result;
}

exports.findUsers = function(userIds) {
	var userQuery = new Parse.Query(Parse.User);
	userQuery.ascending("name");
	userQuery.containedIn("objectId", userIds);
	return userQuery.find();
}

exports.infoForUsers = function(users, includePrefs) {
	var results = []
	for (var i in users) {
		var user = users[i];
		results.push(exports.userInfo(user));
	}
	return results;
};