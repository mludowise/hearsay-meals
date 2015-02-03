var googleKey = "AIzaSyAW7z4SEmncGb9ElHfWlCOn6gejEPm0vHo";

function getParseKeys() {
 	var url = window.location.hostname
	switch (url) {
		case "hearsaymeals.parseapp.com":			// Production
		case "staging-hearsaymeals.parseapp.com":	// Staging
			return {
	    	    applicationId: 'myq9zbMzdkBqqEyudRcwIR5yxnmwihlslqUvYh34',
    	    	restKey: '8Zwn2jGVUZEimJ9YYJUorF305QCAg9qZaWsUVVPZ',
    	    	javascriptKey: 'hqoM0biwivLE3bMwaMDnTRJ9WBY4B8pwmS22zeWx'
			};
		case "mel-hearsaymeals.parseapp.com":
			return {
	    	    applicationId: 'F23K1fxL2OJpfZphfH0lR0Nryz7QCuI1dwIFT6kU',
    	    	restKey: 'i9cpzriov9mLY3oNKXvBZt5xq0lAct8qDBKFuYc1',
    	    	javascriptKey: 'crs0WAmboCZTJLrbL5c9V5ZiIVdrnahWTQEL3Pif'
			};
	}
	return null;
}

function getGoogleClientId() {
 	var url = window.location.hostname
	switch (url) {
		case "hearsaymeals.parseapp.com":			// Production
		case "staging-hearsaymeals.parseapp.com":	// Staging
			return '966122623899-07cog3u9lpipk8q4qo9bvmn51v7h01m5.apps.googleusercontent.com';
		case "mel-hearsaymeals.parseapp.com":
			return '966122623899-49lnd75l3cl4ligdmhgc21nv420ao1l5.apps.googleusercontent.com';
	}
	return null;
}