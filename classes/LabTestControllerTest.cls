@isTest
private class LabTestControllerTest {

    @TestSetup
    static void setup() {
        
         // Create a test Lead
        Lead testLead1 = new Lead();
        testLead1.FirstName = 'Test';
        testLead1.LastName = 'John Doe';
        testLead1.Email = 'test@example.com';
        testLead1.Company = 'Test Company';
        insert testLead1;
        
        //Creating a test Labs_Tests__c
        Labs_Tests__c newTestLabRecord = new Labs_Tests__c();
        newTestLabRecord.Lead__c =testLead1.Id;
        newTestLabRecord.Labs_Tests__c = 'Covid 19';
        Insert newTestLabRecord;
        
        //Creating a test opportunity
         List<opportunity> ExistingOpportunityList = new List<Opportunity>();
        Opportunity existingopp1 = new Opportunity();
        existingopp1.Lead__c = testLead1.Id;
        existingopp1.Name = 'TestOpp1';
        existingopp1.CloseDate = System.Today();
        existingopp1.StageName = 'Closed Lost';
        ExistingOpportunityList.add(existingopp1);
        
        Opportunity existingopp2 = new Opportunity();
        existingopp2.Lead__c = testLead1.Id;
        existingopp2.Name = 'TestOpp2';
        existingopp2.CloseDate = System.Today();
        existingopp2.StageName = 'Closed Lost';
        ExistingOpportunityList.add(existingopp2);
        Insert ExistingOpportunityList;
    }
    
    static testmethod list<string> testlabTestController() {
        
        Lead testLead = [SELECT Id,LastName,FirstName FROM Lead WHERE LastName='John Doe' LIMIT 1];
        Labs_Tests__c Existinglabtest = [SELECT Id,Lead__c,Labs_Tests__c FROM Labs_Tests__c WHERE Lead__C =: testLead.Id];  
        
        Test.StartTest();
        List<String> presult = labTestController.labTestController();
        Test.StopTest();
        System.assertNotEquals(null, presult, 'Result should not be null');
        System.assertEquals(6, presult.size(), 'Expected size of picklistValues list is 6');
        
        return presult;
    }
    
    static testmethod void testcreateLabTestRecord() {
       
       Lead testLead = [SELECT Id,LastName,FirstName FROM Lead WHERE LastName='John Doe' LIMIT 1];
      //Labs_Tests__c Existinglabtest = [SELECT Id,Lead__c,Labs_Tests__c FROM Labs_Tests__c WHERE Lead__C =: testLead.Id];  
        
        List<Labs_Tests__c> existinglabtestRecordList = new List<Labs_Tests__c>();
        Labs_Tests__c existinglabtestRecord = new Labs_Tests__c();
        existinglabtestRecord.Lead__c =testLead.Id;
        existinglabtestRecord.Labs_Tests__c = 'STD';
        existinglabtestRecordList.add(existinglabtestRecord);
        
        Labs_Tests__c existinglabtestRecord1 = new Labs_Tests__c();
        existinglabtestRecord1.Lead__c =testLead.Id;
        existinglabtestRecord1.Labs_Tests__c = 'STD';
        existinglabtestRecordList.add(existinglabtestRecord1);
        Insert existinglabtestRecord1;
        
         ID standardPBID = Test.getStandardPricebookId();
        Product2 prod = new Product2();
        prod.Name = existinglabtestRecord1.Labs_Tests__c;
        Insert prod;
      
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
        LabTestController.createLabTestRecord(testLead.Id,'STD');
        Test.StopTest();
      
        
        Labs_Tests__c labtests = [SELECT Id,Lead__c,Labs_Tests__c FROM Labs_Tests__c LIMIT 1];
        System.assertNotEquals(Null,labtests);
        //System.assertEquals();
        
        
    }
    
    static testmethod void testcreateLabTestRecordFail() {
        
         Lead testLead = [SELECT Id,LastName,FirstName FROM Lead WHERE LastName='John Doe' LIMIT 1];
      //Labs_Tests__c Existinglabtest = [SELECT Id,Lead__c,Labs_Tests__c FROM Labs_Tests__c WHERE Lead__C =: testLead.Id];  
        
        List<Labs_Tests__c> existinglabtestRecordList = new List<Labs_Tests__c>();
        Labs_Tests__c existinglabtestRecord = new Labs_Tests__c();
        existinglabtestRecord.Lead__c =NULL;
        existinglabtestRecord.Labs_Tests__c = 'STD';
        existinglabtestRecordList.add(existinglabtestRecord);
        
        Labs_Tests__c existinglabtestRecord1 = new Labs_Tests__c();
        existinglabtestRecord1.Lead__c =NULL;
        existinglabtestRecord1.Labs_Tests__c = 'STD';
        existinglabtestRecordList.add(existinglabtestRecord1);
        Insert existinglabtestRecord1;
        
         ID standardPBID = Test.getStandardPricebookId();
        Product2 prod = new Product2();
        prod.Name = existinglabtestRecord1.Labs_Tests__c;
        Insert prod;
      
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
         LabTestController.createLabTestRecord(testLead.Id,'STD');
        Test.StopTest();
    }
   
    static testmethod void testupdateMedicalConditionRecord() {
     
     	Lead testLead = [SELECT Id,LastName,FirstName FROM Lead WHERE LastName='John Doe' LIMIT 1];
        Labs_Tests__c Existinglabtest = [SELECT Id,Lead__c,Labs_Tests__c FROM Labs_Tests__c WHERE Lead__C =: testLead.Id LIMIT 1];   
        
		 Labs_Tests__c UpdateExistinglabtest = new Labs_Tests__c();
         UpdateExistinglabtest.Lead__c =testLead.Id;
         UpdateExistinglabtest.Id = Existinglabtest.Id;
         UpdateExistinglabtest.Labs_Tests__c = 'STD';        
         Update UpdateExistinglabtest;
        
        
        Test.StartTest();
        LabTestController.updateMedicalConditionRecord(Existinglabtest, 'STD');
        Test.StopTest();
        
        Labs_Tests__c Updatelabtests = [SELECT Id,Lead__c,Labs_Tests__c FROM Labs_Tests__c LIMIT 1];
        System.assertEquals(Updatelabtests,UpdateExistinglabtest);
    }
    
    static testmethod void testinsertMedicalConditionRecord() {
        
        Lead testLead = [SELECT Id,LastName,FirstName FROM Lead WHERE LastName='John Doe' LIMIT 1];
        Labs_Tests__c Existinglabtest = [SELECT Id,Lead__c,Labs_Tests__c FROM Labs_Tests__c WHERE Lead__C =: testLead.Id]; 
                
         Labs_Tests__c UpsertExistinglabtest = new Labs_Tests__c();
         UpsertExistinglabtest.Lead__c =testLead.Id;
         UpsertExistinglabtest.Id = Existinglabtest.Id;
         UpsertExistinglabtest.Labs_Tests__c = 'STD';        
         Upsert UpsertExistinglabtest;
        
        Test.StartTest();
        LabTestController.insertMedicalConditionRecord(testLead.Id, 'STD');
        Test.StopTest();
        
        Labs_Tests__c Updatelabtests = [SELECT Id,Lead__c,Labs_Tests__c FROM Labs_Tests__c LIMIT 1];
        System.assertEquals(Updatelabtests,UpsertExistinglabtest);
    }
    
    static testmethod void testcreateOrUpdateOpportunity() {
        
         Lead testLead = [SELECT Id,FirstName,LastName FROM Lead WHERE lastName='John Doe'];
        //Labs_Tests__c newTestLabRecord = [SELECT Id,Lead__c,Labs_Tests__c FROM Labs_Tests__c WHERE Lead__C =: testLead.Id];  
        
        //Creating a test Labs_Tests__c
        Labs_Tests__c newTestLabRecord = new Labs_Tests__c();
        newTestLabRecord.Lead__c =testLead.Id;
        newTestLabRecord.Labs_Tests__c = 'Covid 19';
        Insert newTestLabRecord;
        
        //Creating a test opportunity
         List<opportunity> ExistingOpportunityList = new List<Opportunity>();
        Opportunity existingopp1 = new Opportunity();
        existingopp1.Lead__c = testLead.Id;
        existingopp1.Name = 'TestOpp1';
        existingopp1.CloseDate = System.Today();
        existingopp1.StageName = 'Closed Lost';
        ExistingOpportunityList.add(existingopp1);
        
        Opportunity existingopp2 = new Opportunity();
        existingopp2.Lead__c = testLead.Id;
        existingopp2.Name = 'TestOpp2';
        existingopp2.CloseDate = System.Today();
        existingopp2.StageName = 'Closed Lost';
        ExistingOpportunityList.add(existingopp2);
        Insert ExistingOpportunityList;
        
        //List<opportunity> ExistingOpportunityList = [SELECT Id,Name,CloseDate,StageName,Lead__c FROM Opportunity Where Lead__c=:testLead.Id];
        
        //if(newTestLabRecord!=Null) {
            //if(!ExistingOpportunityList.isEmpty()) {
                ExistingOpportunityList[0].Name = testLead.LastName;
                ExistingOpportunityList[0].CloseDate = System.Today();
                ExistingOpportunityList[0].Stagename ='Closed Won';
                UPDATE ExistingOpportunityList;
            //}else{
            /*
                Opportunity newOpp = new Opportunity();
                newOpp.Name = testLead.LastName;
                newOpp.CloseDate = System.Today();
                newOpp.Stagename ='Closed Won';
                newOpp.Lead__c = testLead.Id;
                Insert newOpp;
			*/
           // }
        //}
        
        
        ID standardPBID = Test.getStandardPricebookId();
        Product2 prod = new Product2();
        prod.Name = newTestLabRecord.Labs_Tests__c;
        Insert prod;
      
        Pricebook2 prb = new Pricebook2();
        prb.Name = 'Standard Pricebook';
        Insert prb;
        
        PricebookEntry pb = new PricebookEntry();
        pb.Product2Id = prod.Id;
        pb.Pricebook2Id = standardPBID;
        pb.UnitPrice =100;
        pb.IsActive = true;
        Insert pb;
        
        List<OpportunityLineItem> OpportunityLineItemList = new List<OpportunityLineItem>();        
        if(pb!=Null) {
            
            OpportunityLineItem existingOppLineItem = new OpportunityLineItem();
            existingOppLineItem.OpportunityId = ExistingOpportunityList[0].Id;
            existingOppLineItem.Quantity = 1;
            existingOppLineItem.TotalPrice = 100;
            existingOppLineItem.PricebookEntryId = pb.Id;
            //existingOppLineItem.Name = 'TestOplineItem'; 
           OpportunityLineItemList.add(existingOppLineItem);
                      
            OpportunityLineItem existingOppLineItem2 = new OpportunityLineItem();
            existingOppLineItem2.OpportunityId = ExistingOpportunityList[0].Id;
            existingOppLineItem2.Quantity = 1;
            existingOppLineItem2.TotalPrice = 100;
            existingOppLineItem2.PricebookEntryId = pb.Id;
            //existingOppLineItem2.Name = 'TestOplineItem2';
            OpportunityLineItemList.add(existingOppLineItem2);
            Insert OpportunityLineItemList;
            if(!OpportunityLineItemList.isEmpty()) {
                delete OpportunityLineItemList;
            }
            
            OpportunityLineItem opline = new OpportunityLineItem();
            opline.OpportunityId = ExistingOpportunityList[0].Id;
            opline.PricebookEntryId = pb.Id;
            opline.Quantity = 1;
            opline.TotalPrice = pb.UnitPrice;
            Insert opline;
            
        }
        
        Test.StartTest();
        LabTestController.createOrUpdateOpportunity(testLead.Id);
        Test.StopTest();
        //Verifying Updating Opportunity           Id,Lead__c,Name,CloseDate,StageName 
        List<Opportunity> UpdateoppExistingList = [SELECT Id,Name,CloseDate,stagename,Lead__c FROM Opportunity];
        //System.assertEquals(ExistingOpportunityList,UpdateoppExistingList);
        //System.assertEquals('Closed Won',UpdateoppExistingList[0].Stagename);
        
        
    }
        
    static testmethod void testcreateOrUpdateOpportunityFail() {
         Test.StartTest();
         Lead testLead = [SELECT Id,FirstName,LastName FROM Lead WHERE lastName='John Doe'];
        Labs_Tests__c newTestLabRecord = [SELECT Id,Lead__c,Labs_Tests__c FROM Labs_Tests__c WHERE Lead__C =: testLead.Id];  
        List<opportunity> ExistingOpportunityList = [SELECT Id,Name,CloseDate,StageName,Lead__c FROM Opportunity Where Lead__c=: newTestLabRecord.Lead__c];
        ExistingOpportunityList.clear();
       /* 
        //Creating a test Labs_Tests__c
        Labs_Tests__c newTestLabRecord = new Labs_Tests__c();
        newTestLabRecord.Lead__c =testLead.Id;
        newTestLabRecord.Labs_Tests__c = 'Covid 19';
        Insert newTestLabRecord;      
        */
        ID standardPBID = Test.getStandardPricebookId();
        Product2 prod = new Product2();
        prod.Name = newTestLabRecord.Labs_Tests__c;
        Insert prod;
      
        Pricebook2 prb = new Pricebook2();
        prb.Name = 'Standard Pricebook';
        Insert prb;
        
        PricebookEntry pb = new PricebookEntry();
        pb.Product2Id = prod.Id;
        pb.Pricebook2Id = standardPBID;
        pb.UnitPrice =100;
        pb.IsActive = true;
        Insert pb;
       
        LabTestController.createOrUpdateOpportunity(testLead.Id);
        Test.StopTest();
        //Verifying Updating Opportunity           Id,Lead__c,Name,CloseDate,StageName 
        List<Opportunity> UpdateoppExistingList = [SELECT Id,Name,CloseDate,stagename,Lead__c FROM Opportunity];
        //System.assertEquals(ExistingOpportunityList,UpdateoppExistingList);
        //System.assertEquals('Closed Won',UpdateoppExistingList[0].Stagename);
        
        
    }
    
}