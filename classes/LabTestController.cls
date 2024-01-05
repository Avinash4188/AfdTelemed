public without sharing class LabTestController {
    @AuraEnabled(cacheable=true)
    public static List<String> labTestController() {
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Labs_Tests__c.Labs_Tests__c.getDescribe();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            picklistValues.add(entry.getLabel());
        }
        system.debug(picklistValues);
        return picklistValues;
    }
    
    @AuraEnabled
    public static void createLabTestRecord(Id leadId, String labTestValue) {
        System.debug(leadId);
        List<Labs_Tests__c> existingRecord =  new List<Labs_Tests__c>();
        try {
            existingRecord = [SELECT Id FROM Labs_Tests__c WHERE Lead__c = :leadId LIMIT 1];
        } catch (QueryException e) {
            existingRecord = null; // No record found, set it to null
        }
        System.debug('existingRecord'+existingRecord);
        if (!existingRecord.isEmpty()) {
            updateMedicalConditionRecord(existingRecord[0], labTestValue);
        } else {
            insertMedicalConditionRecord(leadId, labTestValue);
        }
        
        createOrUpdateOpportunity(leadId);
    }
    
   @TestVisible private static void updateMedicalConditionRecord(Labs_Tests__c existingRecord, String labTestValue) {
        existingRecord.Labs_Tests__c = labTestValue;
        
        try {
            update existingRecord;
        } catch (Exception ex) {
            throw new AuraHandledException('Error updating Medical Condition: ' + ex.getMessage());
        }
    }
    
   @TestVisible private static void insertMedicalConditionRecord(Id leadId, String labTestValue) {
        Labs_Tests__c newRecord = new Labs_Tests__c();
        newRecord.Lead__c = leadId; 
        newRecord.Labs_Tests__c = labTestValue;
        
        try {
            upsert newRecord;
        } catch (Exception ex) {
            throw new AuraHandledException('Error creating Medical Condition: ' + ex.getMessage());
        }
    }
    
    public static void createOrUpdateOpportunity(Id leadId) {
        // Query the Medical_Condition__c record
        Labs_Tests__c medicalCondition = [SELECT Lead__c, Labs_Tests__c FROM Labs_Tests__c WHERE Lead__c = :leadId LIMIT 1];
        system.debug('medicalCondition'+medicalCondition);
        
        Lead leadData = [SELECT Name, Email FROM Lead WHERE Id = :medicalCondition.Lead__c LIMIT 1];
		system.debug('leadData'+leadData);
        if (medicalCondition != null) {
            system.debug('inside Medical Condition if');
            // Query the existing Opportunity
            List<Opportunity> existingOpportunity = [SELECT Id FROM Opportunity WHERE Lead__c = :medicalCondition.Lead__c LIMIT 1];
            system.debug('existingOpportunity'+existingOpportunity);

            if (!existingOpportunity.isEmpty()) {
                // Update the existing Opportunity
                existingOpportunity[0].Name = leadData.Name;
                existingOpportunity[0].CloseDate = Date.today();
                existingOpportunity[0].StageName = 'Closed Won';
                // Update other Opportunity fields here
                system.debug('existingOpportunity');
                update existingOpportunity[0];
                system.debug('update existingOpportunity');
                
            } else {
                system.debug('inside Medical Condition else');
                // Create a new Opportunity
                Opportunity newOpportunity = new Opportunity();
                newOpportunity.Name = leadData.Name;
                newOpportunity.CloseDate = Date.today();
                newOpportunity.StageName = 'Closed Won';
                newOpportunity.Lead__c = medicalCondition.Lead__c;
                // Set other Opportunity fields here
                system.debug('insert existingOpportunity');
                insert newOpportunity;
                system.debug('insert after existingOpportunity');
            }

            // Query the Product with the name 'Acne'
            PricebookEntry acneProduct = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Product2.Name = :medicalCondition.Labs_Tests__c LIMIT 1];
            system.debug('acneProduct'+acneProduct);
            

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