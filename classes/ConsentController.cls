public without sharing class ConsentController {
    @AuraEnabled
    public static List<Consent__c> getConsentRecords() {
        return [SELECT Id, Name, Sort_Order__c FROM Consent__c ORDER BY Sort_Order__c];
    }
    
    @AuraEnabled
    public static String saveConsentLogs(List<String> selectedConsentIds, String leadId) {
        List<Consent_Logs__c> consentLogsToInsert = new List<Consent_Logs__c>();
        
        // Query existing Consent_Logs__c records for the provided Lead
        List<Consent_Logs__c> existingConsentLogs = [SELECT Id, Consent__c, Consent_Check__c
                                                     FROM Consent_Logs__c
                                                     WHERE Lead__c = :leadId];
        
        Set<String> existingConsentIds = new Set<String>();
        Map<String, Consent_Logs__c> consentLogsMap = new Map<String, Consent_Logs__c>();
        
        // Populate the existing Consent_Logs__c records into a map
        for (Consent_Logs__c existingLog : existingConsentLogs) {
            existingConsentIds.add(existingLog.Consent__c);
            consentLogsMap.put(existingLog.Consent__c, existingLog);
        }
        
        for (String consentId : selectedConsentIds) {
            if (existingConsentIds.contains(consentId)) {
                // If a matching Consent record is found, update the Consent_Check__c field
                Consent_Logs__c existingLog = consentLogsMap.get(consentId);
                existingLog.Consent_Check__c = true;
            } else {
                // If no matching Consent record is found, create a new Consent_Logs__c record
                Consent_Logs__c consentLog = new Consent_Logs__c();
                consentLog.Consent__c = consentId;
                consentLog.Consent_Check__c = true;
                consentLog.Lead__c = leadId;
                consentLogsToInsert.add(consentLog);
            }
        }
        
        // Update existing records
        if (!existingConsentLogs.isEmpty()) {
            update existingConsentLogs;
        }
        
        // Insert new records
        if (!consentLogsToInsert.isEmpty()) {
            insert consentLogsToInsert;
        }
        
        return 'Success';
    }
    
    
}