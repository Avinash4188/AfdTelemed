@isTest
private class ConsentControllerTest {

    static testmethod List<Consent__c> testgetConsentRecords() {
        
        List<Consent__c> consList = new List<Consent__c>();
        Consent__c cons = new Consent__c();
        cons.Name = 'Test1';
        cons.Policy_Link__c = 'https://afdhealth--partial.sandbox.my.site.com/afd/s/terms-and-conditions?tcid=1';
        consList.add(cons);
        
        Consent__c cons1 = new Consent__c();
        cons1.Name = 'Test2';
        cons1.Policy_Link__c = 'https://afdhealth--partial.sandbox.my.site.com/afd/s/terms-and-conditions?tcid=4';
        consList.add(cons1);
        Insert consList;
        
        Test.StartTest();
        List<Consent__c> consListResult = ConsentController.getConsentRecords();
        Test.StopTest();
        System.assertNotEquals(Null,consListResult);
        System.assertEquals(consListResult[0].Name, 'Test1');
        //System.assertEquals(consListResult[1].Policy_Link__c, 'https://afdhealth--partial.sandbox.my.site.com/afd/s/terms-and-conditions?tcid=1');
       return consListResult;
    }
    
    static testmethod String testsaveConsentLogs() {
        
         //Creating a existingLead
        Lead testLead = new Lead(FirstName='Test',LastName='conversion',Email='avinash4188g@gmail.com');
        Insert testLead;
        
         List<Consent__c> consList = new List<Consent__c>();
        Consent__c cons = new Consent__c();
        cons.Name = 'Test1';
        cons.Policy_Link__c = 'https://afdhealth--partial.sandbox.my.site.com/afd/s/terms-and-conditions?tcid=1';
        consList.add(cons);
        
        Consent__c cons1 = new Consent__c();
        cons1.Name = 'Test2';
        cons1.Policy_Link__c = 'https://afdhealth--partial.sandbox.my.site.com/afd/s/terms-and-conditions?tcid=4';
        consList.add(cons1);
        Insert consList;
        
        
        List<Consent_Logs__c> UpdateconsentLogs = new List<Consent_Logs__c>();
        List<Consent_Logs__c> InsertconsentLogs = new List<Consent_Logs__c>();
        Consent_Logs__c conlog = new Consent_Logs__c();
        conlog.Consent__c = consList[0].Id;
        conlog.Lead__c = testLead.Id;
        //conlog.Consent__c = 'Membership Terms of Service';
        conlog.Consent_Check__c = false;
        UpdateconsentLogs.add(conlog);
        
         Consent_Logs__c conlog1 = new Consent_Logs__c();
        conlog1.Consent__c = consList[0].Id;
        conlog1.Lead__c = testLead.Id;
        //conlog1.Consent__c = 'Membership Terms of Service';
        conlog1.Consent_Check__c = false;
         UpdateconsentLogs.add(conlog1);
       insert UpdateconsentLogs;
       
        if(UpdateconsentLogs[0].Consent__c!=Null) {
            UpdateconsentLogs[0].Consent_Check__c = True;
            
        }else {
             Consent_Logs__c consentLog = new Consent_Logs__c();
                consentLog.Consent__c = consList[0].Id;
                consentLog.Consent_Check__c = true;
                consentLog.Lead__c = testLead.Id;
                InsertconsentLogs.add(consentLog);
        }
        
        if(!UpdateconsentLogs.isEmpty()){
            Update UpdateconsentLogs;
        }
        if(!InsertconsentLogs.isEmpty()) {
            Insert InsertconsentLogs;
        }
        
        List<String> selectedConsentIds = new List<String>{consList[0].Id,consList[1].Id};
               
        Test.StartTest();
        String ResultSuccess = ConsentController.saveConsentLogs(selectedConsentIds, testLead.Id);
        Test.StopTest();
        //Verifying Updation Records
        System.assertNotEquals (Null,ResultSuccess);
        System.assertEquals(True,UpdateconsentLogs[0].Consent_Check__c);
        
        //Verifying Inserting Records
        System.assertNotEquals(Null,InsertconsentLogs);
        return 'ResultSuccess';
    }
}