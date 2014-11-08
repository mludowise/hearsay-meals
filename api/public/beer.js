var Keg = Parse.Object.extend("Keg");
var BeerRequest = Parse.Object.extend("BeerRequest");

function addBeerRequest(beerType){
    var user = Parse.User.current();
    var beerRequest = new BeerRequest();
    beerRequest.set("user", user);
    beerRequest.set("name", beerType);

    beerRequest.save();
}

function loadBeerRequests(){
    var query = Parse.Query(BeerRequest);
    query.find({
        success: function(results){
            alert("Successfully retrieved " + results.length + " beer requests.");
            // Do something with the returned Parse.Object values
            for (var i = 0; i < results.length; i++) {
                var object = results[i];
                var user = object.get('user');
                alert(object.name + ' - ' + user.name);
            }
        }
    });
}