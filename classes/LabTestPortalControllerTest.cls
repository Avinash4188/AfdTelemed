@isTest
private class LabTestPortalControllerTest {
    
    @TestSetup
    static void setData() {
             
        Account a = new Account();
        a.Name = 'Test Acc';
        insert a;
        
        Opportunity op = new Opportunity();
        op.AccountId = a.Id;
        op.Name = a.Name;
        op.StageName = 'Qualification';
        op.CloseDate = System.today();
        insert op;
        
         //Creating a test Labs_Tests__c
        Labs_Tests__c newTestLabRecord = new Labs_Tests__c();
        newTestLabRecord.Account__c = a.Id;
        newTestLabRecord.Opportunity__c = op.Id;
        newTestLabRecord.Labs_Tests__c = 'Covid 19';
        Insert newTestLabRecord;
    }

    @isTest
    static List<String> testlabTestController() {
        
        Labs_Tests__c labtestRecord = [SELECT Id,Lead__c,Labs_Tests__c FROM Labs_Tests__c LIMIT 1];  
        
        Test.StartTest();
        List<String> presult = LabTestPortalController.labTestController();
        Test.StopTest();
        System.assertNotEquals(Null,presult);
        System.assertEquals(6,presult.size());
        System.assertEquals('Covid 19',presult[0]);
        
        return presult;
    }
    
    @isTest
    static void testcreateLabTestRecord() {
        
        Account accRecord = [SELECT Id,Name FROM Account WHERE Name='Test Acc' LIMIT 1];
        Opportunity OppRecord = [SELECT Id,AccountId FROM Opportunity WHERE AccountId =: accRecord.Id LIMIT 1];
       Labs_Tests__c labtestRecordList = [SELECT Id,Labs_Tests__c,Account__c,Opportunity__c FROM Labs_Tests__c 
                                       WHERE Account__c = :accRecord.Id AND Opportunity__c = :OppRecord.Id  LIMIT 1];
		
       // if(OppRecord.isEmpty()) {
             Opportunity newOpp = new Opportunity();
             newOpp.Name = 'New Opportunity';
             newOpp.AccountId=accRecord.Id;
             newOpp.StageName = 'Prospecting';
             newOpp.CloseDate = Date.today();
            Insert newOpp;
            
            Labs_Tests__c LabTestRecord = new Labs_Tests__c();
                LabTestRecord.Account__c = accRecord.Id;
                LabTestRecord.Opportunity__c = newOpp.Id;
                LabTestRecord.Labs_Tests__c = 'Covid 19';
            insert LabTestRecord;
       // }
        
        ID standardPBID = Test.getStandardPricebookId();
        Product2 prod = new Product2();
        prod.Name ='Covid 19';
        Insert Prod;
        
        Pricebook2 prb = new Pricebook2();
        prb.Name = 'Standard Pricebook';
        prb.IsActive = true;
        Insert prb;
        
        PricebookEntry pb = new PricebookEntry();
        pb.Product2Id = prod.Id;
        pb.Pricebook2Id = standardPBID;
        pb.UnitPrice =100;
        pb.IsActive = true;
        Insert pb;
        
        OpportunityLineItem oli = new OpportunityLineItem();
            oli.OpportunityId = oppRecord.Id;
            oli.PricebookEntryId = pb.Id;
            oli.Quantity = 1;
            oli.TotalPrice = pb.UnitPrice;
            insert oli;
        
       Test.StartTest();
        LabTestPortalController.createLabTestRecord(accRecord.Id, 'Covid 19');
       Test.StopTest();
        System.assertEQuals('Covid 19',labtestRecordList.Labs_Tests__c );
        
    }
    
    @isTest
    static void testcreateLabTestRecordFail() {
        
        Account accRecord = [SELECT Id,Name FROM Account WHERE Name='Test Acc' LIMIT 1];
        Opportunity OppRecord = [SELECT Id,AccountId FROM Opportunity WHERE AccountId =: accRecord.Id LIMIT 1];
        OppRecord.StageName = 'Closed Won';
        update OppRecord;
       Labs_Tests__c labtestRecordList = [SELECT Id,Labs_Tests__c,Account__c,Opportunity__c FROM Labs_Tests__c 
                                       WHERE Account__c = :accRecord.Id AND Opportunity__c = :OppRecord.Id  LIMIT 1];
        
		ID standardPBID = Test.getStandardPricebookId();
        Product2 prod = new Product2();
        prod.Name ='Covid 19';
        Insert Prod;
        
        Pricebook2 prb = new Pricebook2();
        prb.Name = 'Standard Pricebook';
        prb.IsActive = true;
        Insert prb;
        
        PricebookEntry pb = new PricebookEntry();
        pb.Product2Id = prod.Id;
        pb.Pricebook2Id = standardPBID;
        pb.UnitPrice =100;
        pb.IsActive = true;
        Insert pb;
        
          Test.StartTest();
        LabTestPortalController.createLabTestRecord(accRecord.Id, 'Covid 19');
       Test.StopTest();
    }
}