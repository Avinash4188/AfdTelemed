public without sharing class termsOfService {
    @AuraEnabled
    public static void updateLeadData(Id leadId, List<String> checkboxFields) {
        Lead leadToUpdate = [SELECT Id, Membership_Terms_of_Service__c, Medical_Terms_of_Service__c, Privacy_Policy__c, Notice_of_HIPAA_Privacy_Practies__c FROM Lead WHERE Id = :leadId LIMIT 1];

        if (leadToUpdate != null) {
            for (String fieldName : checkboxFields) {
                leadToUpdate.put(fieldName, true);
            }

            update leadToUpdate;
        }
    }
}