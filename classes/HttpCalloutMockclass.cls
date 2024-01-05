@isTest
global class HttpCalloutMockclass implements HttpCalloutMock  {
     global HTTPResponse respond(HTTPRequest req) {
        
        // Create a mock response for the Nearby Search API
        //String mockResponse = '{"results": [{"place_id": "516360"},{"name": "TestName"},{"formatted_address" : "123 Test St"}, {"formatted_phone_number" : "555-555-5555"}]}';
		//String mockResponse = '{"results": [{"place_id": "516360"}, {"formatted_phone_number" : "555-555-5555"}]}';
        String mockResponse = '{"results": [{"place_id": "516360" }]}';
        
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(mockResponse);
        //res.setBody('{"results": {"id": 516360, "name": "test"}}');
        res.setStatusCode(500);
        //res.setStatusCode(200);
        return res;
    }

}