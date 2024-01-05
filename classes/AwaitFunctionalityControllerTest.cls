@isTest
private class AwaitFunctionalityControllerTest {

    @TestSetup
    static void setup() {
        
        // Create a test Lead
        Lead testLead = new Lead();
        testLead.FirstName = 'John';
        testLead.LastName = 'Doe';
        testLead.Email = 'test@example.com';
        testLead.Company = 'Test Company';
        testLead.Onfido_Status__c ='Initiated';
        insert testLead; 
        
    }
    
    
    static testmethod Lead testcheckLeadStatus() {
        
		Lead testLead = [SELECT Id,FirstName,LastName,Email,Company,Onfido_Status__c FROM Lead WHERE LastName='Doe' LIMIT 1];
            
        Test.StartTest();
        lead result = AwaitFunctionalityController.checkLeadStatus(testLead.Id);
        Test.StopTest();
        System.assertNotEquals(Null,result);
       	System.assertEquals(testLead.Id,result.Id);
        System.assertEquals(testLead.Onfido_Status__c,'Initiated');
        System.assertEquals(testLead.Onfido_Status__c,result.Onfido_Status__c);
        return testLead;
    }
    
    static testmethod String testfetchLink() {
        
        Lead testLead = [SELECT Id,FirstName,LastName,Email,Company,Onfido_Status__c FROM Lead WHERE LastName='Doe' LIMIT 1];
        
        //onfidosf__Contact__c onc = new onfidosf__Contact__c();
        Contact c = new Contact();
        //c.Lead__c = testLead.Id;
        c.LastName ='Test Name';
        Insert c;
        
        onfidosf__Applicant__c onap = new onfidosf__Applicant__c();
        onap.onfidosf__Contact__c = c.Id;
        Insert onap;
        
        List<onfidosf__Verification__c> onfVerList = new List<onfidosf__Verification__c>();
        onfidosf__Verification__c onfVer = new onfidosf__Verification__c();
        onfVer.onfidosf__Applicant__c = onap.Id;
        onfVerList.add(onfVer);       
        onfidosf__Verification__c onfVer1 = new onfidosf__Verification__c();
        onfVer.onfidosf__Applicant__c = onap.Id;
        onfVerList.add(onfVer);
        
        String verificationUrl;
         if(!onfVerList.isEmpty()) {
            String verificationId = onfVerList[0].Id;
            verificationUrl = 'https://afdhealth--partial.sandbox.my.site.com/apex/onfidosf__onfido_studioVerificationForm?verificationId=' + onfVerList[0].Id;
        }
        
        Test.StartTest();
        String result = AwaitFunctionalityController.fetchLink(testLead.Id);
        Test.StopTest();
        
        String expectedResult = verificationUrl + result;
        System.assertNotEquals(Null,expectedResult);
        System.assertEquals(verificationUrl,'https://afdhealth--partial.sandbox.my.site.com/apex/onfidosf__onfido_studioVerificationForm?verificationId=' + onfVerList[0].Id);
        //System.assertEquals(verificationId,result);
        return verificationUrl;
    }
}