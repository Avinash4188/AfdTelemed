@isTest
private class termsOfServiceTest {

    static testmethod void testupdateLeadData() {
        
        //create a TestLead 
        Lead testLead = new Lead(
        						FirstName='Test',
        						LastName= 'Lead',
        						Membership_Terms_of_Service__c=false,
            					Medical_Terms_of_Service__c =false,
            					Privacy_Policy__c =false,
								Notice_of_HIPAA_Privacy_Practies__c=false            					
        						);
        Insert testLead;
        
        List<string> checkboxFields = new List<String>{
                                                    'Membership_Terms_of_Service__c',
                                                    'Medical_Terms_of_Service__c',
                                                    'Privacy_Policy__c',
                                                    'Notice_of_HIPAA_Privacy_Practies__c'
                                   				 };
                                                     
        Test.StartTest();
         termsOfService.updateLeadData(testLead.Id, checkboxFields);
        Test.StopTest();
        
        Lead updatedLead = [SELECT Id, Membership_Terms_of_Service__c, Medical_Terms_of_Service__c, Privacy_Policy__c, Notice_of_HIPAA_Privacy_Practies__c 
                    FROM Lead WHERE Id = :testLead.Id LIMIT 1]; 
                
        // Check if the fields are updated
        System.assertEquals(true, updatedLead.Membership_Terms_of_Service__c);
        System.assertEquals(true, updatedLead.Medical_Terms_of_Service__c);
        System.assertEquals(true, updatedLead.Privacy_Policy__c);
        System.assertEquals(true, updatedLead.Notice_of_HIPAA_Privacy_Practies__c);
    }
}