public without sharing class stateSelector {
    @AuraEnabled(cacheable=true)
    public static List<String> stateSelector() {
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Lead.State__c.getDescribe();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            picklistValues.add(entry.getLabel());
        }
        system.debug(picklistValues);
        return picklistValues;
    }

    @AuraEnabled
    public static void updateState(Id leadId, String stateValue) {
        
        Lead leadToUpdate = new Lead(Id = leadId);
        leadToUpdate.State__c = stateValue;

        try {
            update leadToUpdate;
            System.debug('Lead updated successfully.');
        } catch (Exception ex) {
            throw new AuraHandledException('Error creating Labs/Test: ' + ex.getMessage());
        }
    }

}