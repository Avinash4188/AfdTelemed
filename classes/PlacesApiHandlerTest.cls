@isTest
public class PlacesApiHandlerTest  {
    static testmethod List<Map<String, Object>> testgetPlaceDetailsListSuccess() {    
        
      // Set the mock callout for the test
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockclass());
/*
        Map<String, Object> extractedDetails = new Map<String, Object>();
               extractedDetails.put('place_id', '516360');
                extractedDetails.put('Name', 'Test Place');
                extractedDetails.put('formatted_address', '123 Test St');
                extractedDetails.put('formatted_phone_number', '555-555-5555');
*/        
        Test.StartTest();
        List<Map<String, Object>> placeDetailsList = PlacesApiHandler.getPlaceDetailsList('516360');
        Test.StopTest();
        // Verify the results
        System.assertEquals(1, placeDetailsList.size());
        Map<String, Object> placeDetails = placeDetailsList[0];
        System.assertEquals('516360', placeDetails.get('Id'));
        System.assertEquals('TestName',placeDetails.get('name'));
        
        return placeDetailsList;
    }
    
    static testmethod List<Map<String, Object>> testgetPlaceDetailsListFail() {
        
         // Set the mock callout for the test
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockclass());
        
        Test.StartTest();
        List<Map<String, Object>> placeDetailsList = PlacesApiHandler.getPlaceDetailsList('516360');
        Test.StopTest();
        // Verify the results
        System.assertEquals(0, placeDetailsList.size());
        
        return placeDetailsList;
    }
    
    
    static testmethod string testbuildQueryString() {
        
        Map<String,String> params = new Map<String,String>();
        params.put('param1', 'value1');
        params.put('param2', 'value2');
        
        Test.StartTest();
        String result = PlacesApiHandler.buildQueryString(params);
        Test.StopTest();
        System.assertEquals('param1=value1&param2=value2', result);
		
        return result;
    }
    
    static testmethod Id testupdateLeadPharmacy() {
        
        Id resultId;
        try{
            
         //Create a test Lead
        Lead testLead = new Lead();
        testLead.FirstName = 'John';
        testLead.LastName = 'Doe';
        testLead.Email = 'test@example.com';
        testLead.Company = 'Test Company';
        insert testLead; 
        
		Map<String, Object> pharmacyInfo = new Map<String, Object>();
        pharmacyInfo.put('Name', 'Test Pharmacy');
        pharmacyInfo.put('Address__c', '123 Test St');
        pharmacyInfo.put('Phone__c', '555-555-5555');
        
        Test.StartTest();
         resultId = PlacesApiHandler.updateLeadPharmacy(testLead.Id, pharmacyInfo);
        Test.StopTest();

		Pharmacy_Location__c insertedPharmacy = [SELECT Id, Name, Lead__c, Address__c, Phone__c FROM Pharmacy_Location__c WHERE Id = :resultId];        
        // Verify that the Pharmacy_Location__c record was created correctly
        System.assertEquals('Test Pharmacy', insertedPharmacy.Name);
        System.assertEquals(testLead.Id, insertedPharmacy.Lead__c);
        System.assertEquals('123 Test St', insertedPharmacy.Address__c);
        System.assertEquals('555-555-5555', insertedPharmacy.Phone__c);
        
        }Catch (Exception ex) {
            System.assertEquals('Error creating' + ex.getMessage(), ex.getMessage());
        }       
        return resultId;
    }
    
}