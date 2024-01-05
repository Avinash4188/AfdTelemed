@isTest()
private class MedicalConditionControllerTest {
    
     @TestSetup
    static void setupData() {
        
        // Create a test Lead
        Lead testLead = new Lead();
        testLead.FirstName = 'John';
        testLead.LastName = 'Doe';
        testLead.Email = 'test@example.com';
        testLead.Company = 'Test Company';
        insert testLead; 
        
       // Create a test Medical_Condition__c
       Medical_Condition__c mc = new Medical_Condition__c();
       mc.Lead__c = testLead.Id;
       mc.List_Of_Medical_Condition__c = 'ADHD';
       Insert mc;
    }
    
    static testmethod List<String> testMedicalConditionController() {
      
        //From testSetup
        Lead testLead = [SELECT Id,FirstName,LastName FROM Lead WHERE LastName='Doe' LIMIT 1];
        Medical_Condition__c mc = [SELECT Id,Lead__c,List_Of_Medical_Condition__c FROM Medical_Condition__c WHERE Lead__c=:testLead.Id LIMIT 1];
       
        // Call the method to get picklist values
        Test.StartTest();
        List<String> picklistValues = MedicalConditionController.MedicalConditionController();
		Test.StopTest();
        
        System.assertNotEquals(null, picklistValues, 'Result should not be null');
        System.assertEquals(36, picklistValues.size(), 'Expected size of picklistValues list is 36');
        System.assertEquals('Acne',picklistValues[0]);
        return picklistValues;
    }
    
    
    static testmethod void createMedicalConditionRecord() {
        
      //From testSetup  
      Lead testLead = [SELECT Id,FirstName,LastName FROM Lead WHERE LastName='Doe' LIMIT 1];
      Medical_Condition__c mc = [SELECT Id,Lead__c,List_Of_Medical_Condition__c FROM Medical_Condition__c WHERE Lead__c=:testLead.Id LIMIT 1]; 
        
        Test.StartTest();
        try {
        MedicalConditionController.createMedicalConditionRecord(testLead.Id,'Birth Control');
        }Catch (Exception ex) {
             System.debug('Exception caught: ' + ex.getMessage());
        }
        Test.StopTest();
        
        Medical_Condition__c mcList = [SELECT Id,List_Of_Medical_Condition__c FROM Medical_Condition__c WHERE Id=:mc.Id];
        System.assertNotEquals(Null,mcList);
        System.assertEquals('Birth Control',mcList.List_Of_Medical_Condition__c);
    }
    
    
    static testmethod void testUpdateMedicalConditionRecord() {
        
        //From testSetup 
       Lead testLead = [SELECT Id,FirstName,LastName FROM Lead WHERE LastName='Doe' LIMIT 1];
       Medical_Condition__c mc = [SELECT Id,Lead__c,List_Of_Medical_Condition__c FROM Medical_Condition__c WHERE Lead__c=:testLead.Id LIMIT 1];
        
        // Call the updateMedicalConditionRecord method
        Test.StartTest();
        
        try {
            MedicalConditionController.updateMedicalConditionRecord(mc, 'Fertility');
        } catch (Exception ex) {
            // Make sure no exceptions are thrown here
            System.assert(false, 'Exception thrown: ' + ex.getMessage());
        }
        Test.StopTest();
        
        mc = [SELECT Id, List_Of_Medical_Condition__c FROM Medical_Condition__c WHERE Id = :mc.Id];
        System.assertEquals('Fertility', mc.List_Of_Medical_Condition__c);
       

    }
    static testmethod void testInsertMedicalConditionRecord() {
        
        //From testSetup 
       Lead testLead = [SELECT Id,FirstName,LastName FROM Lead WHERE LastName='Doe' LIMIT 1];
       Medical_Condition__c mc = [SELECT Id,Lead__c,List_Of_Medical_Condition__c FROM Medical_Condition__c WHERE Lead__c=:testLead.Id LIMIT 1];
        
        Test.StartTest();
        MedicalConditionController.insertMedicalConditionRecord(testLead.Id,'ADHD');
        Test.StopTest();
        
 		Medical_Condition__c mcList = [SELECT Id,List_Of_Medical_Condition__c FROM Medical_Condition__c WHERE Id =: mc.Id];
        System.assertNotEquals(Null,mcList);
        System.assertEquals('ADHD',mcList.List_Of_Medical_Condition__c);
        
    }
    
    static testmethod void testInsertMedicalConditionRecordFail() {
        
        
        //From testSetup 
       Lead testLead = [SELECT Id,FirstName,LastName FROM Lead WHERE LastName='Doe' LIMIT 1];
       Medical_Condition__c mc = [SELECT Id,Lead__c,List_Of_Medical_Condition__c FROM Medical_Condition__c WHERE Lead__c=:testLead.Id LIMIT 1];
        
        
        Test.startTest();
        try {
            MedicalConditionController.insertMedicalConditionRecord(null,null);
        } catch (Exception ex) {
            // Verify that the correct error message is throw
           throw new AuraHandledException('Error updating Medical Condition: ' + ex.getMessage());
        }
        Test.stopTest();
        
    }
    
    static testmethod void testcreateOrUpdateOpportunity() {
        
         Lead testLead = [SELECT Id,Name,FirstName,LastName FROM Lead WHERE LastName='Doe' LIMIT 1];
        Medical_Condition__c mc = [SELECT Id,Lead__c,List_Of_Medical_Condition__c FROM Medical_Condition__c WHERE Lead__c=:testLead.Id LIMIT 1];
        
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
        
        if(mc!=Null) {
            if(!ExistingOpportunityList.isEmpty()) {
                ExistingOpportunityList[0].Name = testLead.Name;
                ExistingOpportunityList[0].CloseDate = System.Today();
                ExistingOpportunityList[0].Stagename ='Closed Won';
                UPDATE ExistingOpportunityList;
            }else{
                Opportunity newOpp = new Opportunity();
                newOpp.Name = testLead.Name;
                newOpp.CloseDate = System.Today();
                newOpp.Stagename ='Closed Won';
                newOpp.Lead__c = testLead.Id;
                Insert newOpp;
            }
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
            existingOppLineItem2.OpportunityId = ExistingOpportunityList[1].Id;
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
        MedicalConditionController.createOrUpdateOpportunity(testLead.Id);
        Test.StopTest();
        //Verifying Updating Opportunity
        List<Opportunity> UpdateoppExistingList = [SELECT Id,Name,CloseDate,stagename,Lead__c FROM Opportunity WHERE Lead__c =:testLead.Id];
        System.assertEquals(UpdateoppExistingList,ExistingOpportunityList);
        System.assertEquals(UpdateoppExistingList[0].Stagename,'Closed Won');
        
        /*
        //Verifying Inserting Opportunity
        Opportunity oppInsert = [SELECT Id,Name,CloseDate,stagename,Lead__c FROM Opportunity WHERE Lead__c =:testLead.Id];
        System.assertEquals(oppInsert,newOpp);
        */
        
        //Veryfing Deleting existingOpportunityLineItem
        List<OpportunityLineItem> DeletexistingOpportunityLineItems = [SELECT Id,Quantity,OpportunityId,TotalPrice,PricebookEntryId FROM OpportunityLineItem WHERE OpportunityId=: ExistingOpportunityList];
        //System.assertEquals(DeletexistingOpportunityLineItems,OpportunityLineItemList);
        Delete DeletexistingOpportunityLineItems;
        //System.assertEquals(DeletexistingOpportunityLineItems,Null);
        
        /*
        //Verifying Inserting new OpportunityLineItem
        OpportunityLineItem insertNewOpportunityLineItem = [SELECT Id,Quantity,OpportunityId,TotalPrice,PricebookEntryId FROM OpportunityLineItem WHERE OpportunityId=: ExistingOpportunityList];
        System.assertEquals(insertNewOpportunityLineItem,opline);
		*/
    }
    
    
}