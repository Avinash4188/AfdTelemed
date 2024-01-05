public without sharing class PicklistController {
    @AuraEnabled(cacheable=true)
    public static List<String> getPicklistValues() {
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Medical_Condition__c.List_Of_Medical_Condition__c.getDescribe();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            picklistValues.add(entry.getLabel());
        }
        return picklistValues;
    }
}