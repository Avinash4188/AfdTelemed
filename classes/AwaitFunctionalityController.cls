public without sharing class AwaitFunctionalityController {
    @AuraEnabled
    public static Lead checkLeadStatus(Id leadId) {
        system.debug(leadId);
        Lead leadRecord = [SELECT Onfido_Status__c FROM Lead WHERE Id = :leadId LIMIT 1];
        system.debug(leadRecord);
        return leadRecord;
    }
    @AuraEnabled
    public static String fetchLink(String leadId) {
        String verificationUrl;
        List<onfidosf__Verification__c> verificationList = [SELECT Id FROM onfidosf__Verification__c WHERE onfidosf__Applicant__r.onfidosf__Contact__r.Lead__c = :leadId LIMIT 1];
        
        if (!verificationList.isEmpty()) {
            String verificationId = verificationList[0].Id;
            verificationUrl = 'https://afdhealth--partial.sandbox.my.site.com/apex/onfidosf__onfido_studioVerificationForm?verificationId=' + verificationId;
        }
        
        return verificationUrl;
    }    
}