public with sharing class MedicalConditionOpportunityCreation {

    public static void createOrUpdateOpportunity(Id leadId) {
        // Query the Medical_Condition__c record
        Medical_Condition__c medicalCondition = [SELECT Lead__c, List_Of_Medical_Condition__c FROM Medical_Condition__c WHERE Lead__c = :leadId LIMIT 1];
        
        Lead leadData = [SELECT Name, Email FROM Lead WHERE Id = :medicalCondition.Lead__c LIMIT 1];

        if (medicalCondition != null) {
            // Query the existing Opportunity
            Opportunity existingOpportunity = [SELECT Id FROM Opportunity WHERE Lead__c = :medicalCondition.Lead__c LIMIT 1];

            if (existingOpportunity != null) {
                // Update the existing Opportunity
                existingOpportunity.Name = leadData.Name;
                existingOpportunity.CloseDate = Date.today();
                existingOpportunity.StageName = 'Closed Won';
                // Update other Opportunity fields here
                update existingOpportunity;
            } else {
                // Create a new Opportunity
                Opportunity newOpportunity = new Opportunity();
                newOpportunity.Name = leadData.Name;
                newOpportunity.CloseDate = Date.today();
                newOpportunity.StageName = 'Closed Won';
                newOpportunity.Lead__c = medicalCondition.Lead__c;
                // Set other Opportunity fields here
                insert newOpportunity;
            }

            // Query the Product with the name 'Acne'
            PricebookEntry acneProduct = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Product2.Name = :medicalCondition.List_Of_Medical_Condition__c LIMIT 1];

            if (acneProduct != null) {
                Opportunity existingOpp = [SELECT Id FROM Opportunity WHERE Lead__c = :medicalCondition.Lead__c LIMIT 1];
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
}