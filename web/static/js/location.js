(function() { 
var x = $("[id=user-lat]");
var y = $("[id=user-long]");


function getLocation(){
	if(navigator.geolocation){
		navigator.geolocation.getCurrentPosition(showPosition, showError);
	}
	else {
		x.innerHTML = "Geolocation is not supported by this browser";
	}
};

function showPosition(position) {
	var  latlon = position.coords.latitude + "," + position.coords.longitude;
	x.each(function(data) {
		$(this).val(position.coords.latitude);
	});

	y.each(function(data) {
		$(this).val(position.coords.longitude);
	})
	//var img_url ="http://maps.googleapis.com/maps/api/staticmap?center="+latlon+"&zoom=14&size=400x300&sensor=false";
	//$('#mapholder').html("<img src='"+img_url+"'>");
};

function showError(error) {
	switch(error.code){
		case error.PERMISSION_DENIED:
			x.innerHTML = "User denied the request for Geolocation.";
			break;
		case error.POSITION_UNAVAILABLE:
			x.innerHTML = "Location information is unavailable";
			break;
		case error.TIMEOUT:
			x.innerHTML = "The request to get user location timed out.";
			break;
		case error.UNKNOWN_ERROR:
			x.innerHTML = "an unknown error occured.";
			break;
	};
}
getLocation();

})();
