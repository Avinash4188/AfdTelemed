public with sharing class PlacesApiHandler {
    @AuraEnabled
    public static List<Map<String, Object>> getPlaceDetailsList(String zipCode) {
        String apiKey = 'AIzaSyBeq7Gen8UdQq3KeOBaL3kgurNitvJNzr4';
        //String nearbySearchEndpoint = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
        String nearbySearchEndpoint  = 'https://maps.googleapis.com/maps/api/place/textsearch/json';
        String placeDetailsEndpoint = 'https://maps.googleapis.com/maps/api/place/details/json';
        String query = 'Pharmacies%near%pin%code%'+zipCode;
        // Step 1: Get a list of place IDs using the Nearby Search API
        List<String> placeIds = new List<String>();
        
        // Set up parameters for the Nearby Search API request
        Map<String, String> nearbySearchParams = new Map<String, String>();
         // Use latitude and longitude instead of the zip code if possible
        //nearbySearchParams.put('radius', '5000');
        // nearbySearchParams.put('type', 'pharmacy'); 
        //nearbySearchParams.put('location', zipCode);// Adjust the radius as needed
        nearbySearchParams.put('key', apiKey);
        nearbySearchParams.put('query', query);
        
        // Make the HTTP request to the Nearby Search API
       HttpRequest nearbySearchReq = new HttpRequest();
        //nearbySearchReq.setEndpoint('https://maps.googleapis.com/maps/api/place/nearbysearch/json?radius=5000&type=pharmacy&location=18.5045902%2C73.7654297&key=AIzaSyBeq7Gen8UdQq3KeOBaL3kgurNitvJNzr4');
        nearbySearchReq.setEndpoint(nearbySearchEndpoint + '?'  + buildQueryString(nearbySearchParams));
        nearbySearchReq.setMethod('GET');
        nearbySearchReq.setHeader('Content-Type', 'application/json');
        //nearbySearchReq.setBody(buildQueryString(nearbySearchParams)); // Construct the query string
        System.debug('nearbySearchReq'+nearbySearchReq);
        Http nearbySearchHttp = new Http();
        HttpResponse nearbySearchRes = nearbySearchHttp.send(nearbySearchReq);
        System.debug('nearbySearchRes'+nearbySearchRes);
        // Parse the Nearby Search API response and extract place IDs
        if (nearbySearchRes.getStatusCode() == 200) {
            Map<String, Object> nearbySearchResponse = (Map<String, Object>)JSON.deserializeUntyped(nearbySearchRes.getBody());
            List<Object> results = (List<Object>)nearbySearchResponse.get('results');
            System.debug('results'+results);
            for (Object result : results) {
                Map<String, Object> place = (Map<String, Object>)result;
                String placeId = (String)place.get('place_id');
                placeIds.add(placeId);
            }
        } else {
            // Handle error cases if needed
            System.debug('Error fetching nearby places: ' + nearbySearchRes.getStatusCode() );
        }
        
        // Step 2: Get place details for each place ID using the Place Details API
        List<Map<String, Object>> placeDetailsList = new List<Map<String, Object>>();
        System.debug('placeIds'+placeIds);
        integer flag = 0;
        for (String placeId : placeIds) {
            // Set up parameters for the Place Details API request
            Map<String, String> placeDetailsParams = new Map<String, String>();
            placeDetailsParams.put('place_id', placeId);
            placeDetailsParams.put('key', apiKey);
            
            // Make the HTTP request to the Place Details API
            HttpRequest placeDetailsReq = new HttpRequest();
            placeDetailsReq.setEndpoint(placeDetailsEndpoint + '?'  + buildQueryString(placeDetailsParams));
            placeDetailsReq.setMethod('GET');
            Http placeDetailsHttp = new Http();
            HttpResponse placeDetailsRes = placeDetailsHttp.send(placeDetailsReq);
            
			System.debug('placeDetailsRes'+placeDetailsRes);
            // Parse the Place Details API response and add it to the list
            if (placeDetailsRes.getStatusCode() == 200) {
                System.debug('placeDetailsRes&&&' + placeDetailsRes);
                Map<String, Object> placeDetailsResponse = (Map<String, Object>)JSON.deserializeUntyped(placeDetailsRes.getBody());
                Map<String, Object> placeDetails = (Map<String, Object>)placeDetailsResponse.get('result');
                 Map<String, Object> extractedDetails = new Map<String, Object>();
                System.debug('placeDetails****'+placeDetails);
                extractedDetails.put('Id', placeDetails.get('place_id'));
                extractedDetails.put('name', placeDetails.get('name'));
                extractedDetails.put('formatted_address', placeDetails.get('formatted_address'));
                extractedDetails.put('formatted_phone_number', placeDetails.get('formatted_phone_number'));
                extractedDetails.put('item_Id', 'radio'+flag++);
                placeDetailsList.add(extractedDetails);
                System.debug('placeDetailsList'+extractedDetails);
            } else {
                // Handle error cases if needed
                System.debug('Error fetching place details for place ID ' + placeId + ': ' + placeDetailsRes.getStatusCode());
            }
        }
        
        return placeDetailsList;
    }
    // Helper method to build a query string from a map of parameters
    public static String buildQueryString(Map<String, String> params) {
        List<String> keyValuePairs = new List<String>();
        for (String key : params.keySet()) {
            keyValuePairs.add(key + '=' + EncodingUtil.urlEncode(params.get(key), 'UTF-8'));
        }
        return String.join(keyValuePairs, '&');
    }
    
    @AuraEnabled
    public static Id updateLeadPharmacy(String leadId, Map<String, Object> pharmacyInfo) {
        try{
            Pharmacy_Location__c pharmacyLocation = new Pharmacy_Location__c();
            
            pharmacyLocation.Name = (String)pharmacyInfo.get('Name');
            pharmacyLocation.Lead__c = leadId;
            pharmacyLocation.Address__c = (String)pharmacyInfo.get('Address__c');
            pharmacyLocation.Phone__c = (String)pharmacyInfo.get('Phone__c');
            System.debug(pharmacyLocation);
            // Insert the record
            insert pharmacyLocation;
            
            return pharmacyLocation.Id;
        }catch (Exception ex) {
            // Handle any exceptions or errors here
            throw new AuraHandledException('Error creating Baseline Health Overview record: ' + ex.getMessage());
        }
    }
    
}