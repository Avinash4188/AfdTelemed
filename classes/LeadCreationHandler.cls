public without sharing class LeadCreationHandler {
    @AuraEnabled(cacheable=true)
    public static Lead getLeadData(String leadId) {
        return [SELECT Id, FirstName, LastName, Company, HealthCloudGA__BirthDate__c, HealthCloudGA__Gender__c, Phone FROM Lead WHERE Id = :leadId LIMIT 1];
    }

    @AuraEnabled
    public static void updateLeadData(Lead leadData) {
        try {
            Lead leadToUpdate = [SELECT Id FROM Lead WHERE Id = :leadData.Id];
            leadToUpdate.FirstName = leadData.FirstName;
            leadToUpdate.LastName = leadData.LastName;
            leadToUpdate.Company = leadData.Company;
            leadToUpdate.HealthCloudGA__BirthDate__c = leadData.HealthCloudGA__BirthDate__c;
            leadToUpdate.HealthCloudGA__Gender__c = leadData.HealthCloudGA__Gender__c;
            leadToUpdate.Phone = leadData.Phone;
            
            upsert leadToUpdate;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}