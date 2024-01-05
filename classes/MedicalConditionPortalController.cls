public without sharing class MedicalConditionPortalController {
    @AuraEnabled(cacheable=true)
    public static List<String> MedicalConditionController() {
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Medical_Condition__c.List_Of_Medical_Condition__c.getDescribe();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            picklistValues.add(entry.getLabel());
        }
        system.debug(picklistValues);
        return picklistValues;
    }
    
    @AuraEnabled
    public static void createMedicalConditionRecord(Id accountId, String conditionValue) {
        // Check if an Opportunity exists for the given AccountId
        List<Opportunity> existingOpportunity = [SELECT Id, Name FROM Opportunity WHERE AccountId = :accountId AND StageName != 'Closed Won' LIMIT 1];
        System.debug('existingOpportunity: ' + existingOpportunity);
        if (existingOpportunity.isEmpty()) {
            // Create a new Opportunity
            Opportunity newOpportunity = new Opportunity(
                Name = 'New Opportunity',
                AccountId = accountId,
                StageName = 'Prospecting', // You can set the appropriate stage
                CloseDate = Date.today()
            );
            insert newOpportunity;
            System.debug('newOpportunity: ' + newOpportunity);
            
            // Create a Medical_Condition__c record
            Medical_Condition__c conditionValueRecord = new Medical_Condition__c(
                Account__c = accountId,
                Opportunity__c = newOpportunity.Id,
                List_Of_Medical_Condition__c = conditionValue
            );
            insert conditionValueRecord;
            
        } else {
            // Update the existing Opportunity
            existingOpportunity[0].Name = 'Updated Opportunity';
            update existingOpportunity;
            
            // Find the related Medical_Condition__c record
            Medical_Condition__c existingconditionValue = [SELECT Id, List_Of_Medical_Condition__c FROM Medical_Condition__c WHERE Account__c = :accountId AND Opportunity__c = :existingOpportunity[0].Id LIMIT 1];
            
            if (existingconditionValue != null) {
                // Update the existing Medical_Condition__c record
                existingconditionValue.List_Of_Medical_Condition__c = conditionValue;
                update existingconditionValue;
            } else {
                // Create a new Medical_Condition__c record
                Medical_Condition__c newconditionValue = new Medical_Condition__c(
                    Account__c = accountId,
                    Opportunity__c = existingOpportunity[0].Id,
                    List_Of_Medical_Condition__c = conditionValue
                );
                insert newconditionValue;
            }
        }
        
        // Query the Product with the name 'Acne'
        PricebookEntry acneProduct = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Product2.Name = :conditionValue LIMIT 1];
        system.debug('acneProduct'+acneProduct);
        
        
        if (acneProduct != null) {
            Opportunity existingOpp = [SELECT Id FROM Opportunity WHERE AccountId = :accountId AND StageName != 'Closed Won' LIMIT 1];
            system.debug('existingOpp'+existingOpp);
            // Delete existing Opportunity Line Items
            List<OpportunityLineItem> existingOpportunityLineItems = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :existingOpp.Id];
            system.debug('existingOpportunityLineItems'+existingOpportunityLineItems);
            if (!existingOpportunityLineItems.isEmpty()) {
                system.debug('before delete');
                delete existingOpportunityLineItems;
                system.debug('After delete');
            }
            
            // Create a new OpportunityLineItem
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.OpportunityId = existingOpp.Id;
            oli.PricebookEntryId = acneProduct.Id;
            oli.Quantity = 1;
            oli.TotalPrice = acneProduct.UnitPrice;
            system.debug('oli'+oli);
            
            // Insert the new OpportunityLineItem
            insert oli;
            system.debug('oliAfterInsertr'+oli);
        }
        
    }
}