@isTest
private class LeadCreationHandlerTest {

    static testmethod Lead testGetLeadData() {
        
        // Create a test Lead
        Lead testLead = new Lead();
        testLead.FirstName = 'John';
        testLead.LastName = 'Doe';
        testLead.Email = 'test@example.com';
        testLead.Company = 'Test Company';
        testLead.HealthCloudGA__BirthDate__c = Date.newInstance(1990, 1, 1);
        testLead.HealthCloudGA__Gender__c = 'Male';
        testLead.Phone = '1234567890';
        insert testLead;
        
        Test.StartTest();
         Lead result = LeadCreationHandler.getLeadData(testLead.Id);
        Test.StopTest();
        
        // Verify the result
        System.assertEquals('John', result.FirstName);
        System.assertEquals('Doe', result.LastName);
        System.assertEquals('Test Company', result.Company);
        System.assertEquals(Date.newInstance(1990, 1, 1), result.HealthCloudGA__BirthDate__c);
        System.assertEquals('Male', result.HealthCloudGA__Gender__c);
        System.assertEquals('1234567890', result.Phone);
        
        return result;
    }
    
    static testmethod void updateLeadData() {
        
        Lead testLeads = new Lead(
            FirstName = 'Jane',
            LastName = 'Doe',
            Company = 'Test Company',
            HealthCloudGA__BirthDate__c = Date.newInstance(1985, 5, 5),
            HealthCloudGA__Gender__c = 'Female',
            Phone = '0987654321'
        );
        insert testLeads;
        
        // Modify lead data
        testLeads.FirstName = 'Updated First Name';
        testLeads.LastName = 'Updated Last Name';
        testLeads.Company = 'Updated Company';
        testLeads.HealthCloudGA__BirthDate__c = Date.newInstance(2000, 12, 31);
        testLeads.HealthCloudGA__Gender__c = 'Other';
        testLeads.Phone = '5555555555';
        
        // Call the updateLeadData method
        Test.startTest();
        LeadCreationHandler.updateLeadData(testLeads);
        Test.stopTest();
        
        // Verify the lead data has been updated
        Lead updatedLead = [SELECT FirstName, LastName, Company, HealthCloudGA__BirthDate__c, HealthCloudGA__Gender__c, Phone FROM Lead WHERE Id = :testLeads.Id];
        System.assertEquals('Updated First Name', updatedLead.FirstName);
        System.assertEquals('Updated Last Name', updatedLead.LastName);
        System.assertEquals('Updated Company', updatedLead.Company);
        System.assertEquals(Date.newInstance(2000, 12, 31), updatedLead.HealthCloudGA__BirthDate__c);
        System.assertEquals('Other', updatedLead.HealthCloudGA__Gender__c);
        System.assertEquals('5555555555', updatedLead.Phone);
    }
    
}