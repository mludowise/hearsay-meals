var googleKey = "AIzaSyAW7z4SEmncGb9ElHfWlCOn6gejEPm0vHo";

function getParseKeys() {
 	var url = window.location.hostname
	switch (url) {
		case "hearsaymeals.parseapp.com":
			return {
	    	    'X-Parse-Application-Id': 'myq9zbMzdkBqqEyudRcwIR5yxnmwihlslqUvYh34',
    	    	'X-Parse-REST-API-Key': '8Zwn2jGVUZEimJ9YYJUorF305QCAg9qZaWsUVVPZ'
			};
		case "staging-hearsaymeals.parseapp.com":
			return {
	    	    'X-Parse-Application-Id': 'ryopGELyjc2gdNRLbOcFJCWu0QKorxgF7wNcvoSd',
    	    	'X-Parse-REST-API-Key': 'ByYhD17CyRjzUdpNlyiWzH2qhT09LhhDtSP4X8ER'
			};
		case "mel-hearsaymeals.parseapp.com":
			return {
	    	    'X-Parse-Application-Id': 'F23K1fxL2OJpfZphfH0lR0Nryz7QCuI1dwIFT6kU',
    	    	'X-Parse-REST-API-Key': 'i9cpzriov9mLY3oNKXvBZt5xq0lAct8qDBKFuYc1'
			};
		default:
			return null;
	}
}

function getGoogleClientId() {
 	var url = window.location.hostname
	switch (url) {
		case "staging-hearsaymeals.parseapp.com":
			return '966122623899-407mp3e3ai9291tegm1e7rnh8vemfn5p.apps.googleusercontent.com';
		case "mel-hearsaymeals.parseapp.com":
			return '966122623899-a09be0hictilu42qa7v1gtu7ue5kvnc2.apps.googleusercontent.com';
		default: // "hearsaymeals.parseapp.com"
			return '966122623899-07cog3u9lpipk8q4qo9bvmn51v7h01m5.apps.googleusercontent.com';
	}
}