@isTest
Private class MedicalConditionPortalControllerTest {

    @TestSetup
    static void setData(){
        
        //Create a test Account
        Account a = new Account();
        a.Name ='Test Company';
        insert a;
        
        //Create a test Opportunity
        Opportunity opp = new Opportunity();
        opp.AccountId = a.Id;
        opp.Name = a.Name;
        opp.StageName ='Qualification';
        opp.CloseDate = System.today();
        insert opp;
        
       // Create a test Medical_Condition__c
       Medical_Condition__c mc = new Medical_Condition__c();
       mc.Account__c = a.Id;
       mc.Opportunity__c = opp.Id;
       mc.List_Of_Medical_Condition__c = 'Acne';
       Insert mc;
    }
    @isTest
    static List<String> testMedicalConditionController() {
        
        Medical_Condition__c mc = [SELECT Id,Lead__c,List_Of_Medical_Condition__c FROM Medical_Condition__c LIMIT 1];
        
        Test.StartTest();
        List<String> picklistValues = MedicalConditionPortalController.MedicalConditionController();
        Test.StopTest();
        System.assertNotEquals(Null,picklistValues);
        System.assertEquals(36,picklistValues.size());
        System.assertEquals('Acne',picklistValues[0]);
        return picklistValues;
    }
    
    @isTest
    static void testcreateMedicalConditionRecord() {
                
		Account acc = [SELECT Id,Name FROM Account WHERE Name='Test Company' LIMIT 1];      
        List<Opportunity> opp = [SELECT Id,Name FROM Opportunity WHERE AccountId =: acc.Id LIMIT 1];
        Medical_Condition__c mc = [SELECT Id,Lead__c,List_Of_Medical_Condition__c,Opportunity__c FROM Medical_Condition__c
                                   WHERE Account__c =: acc.Id AND Opportunity__c =: opp[0].Id LIMIT 1];
        if(opp.isEmpty()) {
        Opportunity newOpp = new Opportunity();
         newOpp.Name = 'New Opportunity';
         newOpp.AccountId=acc.Id;
         newOpp.StageName = 'Prospecting';
         newOpp.CloseDate = Date.today();
        Insert newOpp;
        
         Medical_Condition__c newMc = new Medical_Condition__c();
         newMc.Account__c = acc.Id;
         newMc.Opportunity__c = newOpp.Id;
         newMc.List_Of_Medical_Condition__c = 'Acne'; 
        Insert newMc;
        }
        
        ID standardPBID = Test.getStandardPricebookId();
        Product2 prod = new Product2();
        prod.Name = mc.List_Of_Medical_Condition__c;
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
            oli.OpportunityId = opp[0].Id;
            oli.PricebookEntryId = pb.Id;
            oli.Quantity = 1;
            oli.TotalPrice = pb.UnitPrice;
            insert oli;
       
        Test.StartTest();
        MedicalConditionPortalController.createMedicalConditionRecord(acc.Id, 'Acne');
        Test.StopTest();
        System.assertEquals('Acne', mc.List_Of_Medical_Condition__c);
     
    }
    
    @isTest
    static void testcreateMedicalConditionRecordFail() {
        
        Account acc = [SELECT Id,Name FROM Account WHERE Name='Test Company' LIMIT 1];      
        Opportunity opp = [SELECT Id,Name,stageName FROM Opportunity WHERE AccountId =: acc.Id LIMIT 1];
        opp.StageName = 'Closed Won';
        update Opp;
        Medical_Condition__c mc = [SELECT Id,Lead__c,List_Of_Medical_Condition__c,Opportunity__c FROM Medical_Condition__c
                                   WHERE Account__c =: acc.Id AND Opportunity__c =: opp.Id LIMIT 1];
       
        ID standardPBID = Test.getStandardPricebookId();
        Product2 prod = new Product2();
        prod.Name = 'Acne';
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
         MedicalConditionPortalController.createMedicalConditionRecord(acc.Id, 'Acne');
        Test.StopTest();
    }
}