public class GetZoomMeetingURLwithInput {

    @InvocableMethod(label='Get Zoom Meeting URL with Input' callout='true')
   public static List<String> makeApiCalloutwithInput(List<String> appointmentId)
   {
       HttpRequest req = new HttpRequest();
       Http http = new Http();
       //Setup the Endpoint and append the name of the file
       req.setEndpoint('callout:SalesforceZoomPOCNC');
       req.setMethod('POST');
       req.setHeader('Content-Type','application/json');
       req.setHeader('Accept','*/*');
       req.setHeader('Accept-Encoding','gzip, deflate, br');
       req.setBody('{"topic": "test create meeting","type": "1"}');      
       HTTPResponse res = http.send(req);
       System.debug('Response Body: '+res.getBody());
       /* Parse Response */
       JSONParser parser = JSON.createParser(res.getBody());
       String webLink;
       webLink = 'ZoomNotSetup';
       while (parser.nextToken() != null) {
       if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
       (parser.getText() == 'join_url')) {
           parser.nextToken();
           webLink = parser.getText();
           System.debug('join_url= ' + webLink);
           }
       }
   return new List<String>{webLink};
   }
}