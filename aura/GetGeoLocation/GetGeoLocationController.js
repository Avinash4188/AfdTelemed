({
	doInit : function(component, event, helper) {
        navigator.geolocation.getCurrentPosition(function(position){
            var geolocation = {
                lat: position.coords.latitude,
                lng: position.coords.longitude
            };
            component.set("v.latitude", geolocation.lat);
            component.set("v.longitude", geolocation.lng);  
        })
    }
})