public without sharing class LeadDataSegregation {
    @AuraEnabled(cacheable=true)
    public static void leadData(String accountId) {
        //updateMedicalCondition(leadId, accountId);
        try { 
            Case recordType = [Select RecordTypeId from Case where RecordType.Name = 'Initial Patient Visit' LIMIT 1];
            Account accountEmail = [Select Id, Name, PersonEmail from Account where Id= :accountId LIMIT 1];
            List<Medical_Condition__c> existingconditionValue = [SELECT Id, List_Of_Medical_Condition__c FROM Medical_Condition__c WHERE Account__c = :accountId LIMIT 1];
            Case newCase = New Case();
            newCase.AccountId = accountId;
            newCase.Subject = accountEmail.Name+' '+date.today();
            newCase.Medical_Conditions__c = existingconditionValue[0].Id;
            newCase.Status = 'New Patient';
            newCase.Origin = 'Web';
            newCase.SuppliedEmail = accountEmail.PersonEmail;
            newCase.RecordTypeId = recordType.RecordTypeId;
            insert newCase;
            
        } catch (Exception e) {
            // Handle any exceptions that may occur
            System.debug('An error occurred for Case: ' + e.getMessage());
        }
        //case caseID = [Select id from case where AccountId = :accountId LIMIT 1];
        //updateBaselineHealthOverview(leadId, accountId);
       // updatePharmacy(leadId, accountId);
        //updateBaselineResponse(leadId, accountId, caseID.Id);
        //updateStripe(leadId, accountId);
        //updateConsent(leadId, accountId);
        //moveFilesToAccount(leadId, accountId, caseID.Id);
        
        //updateOpportunity(leadId, accountId);
        
        
    }
    // Helper methods to update lookup fields for each object
   @TestVisible private static void updateBaselineHealthOverview(Id leadId, Id accountId) {
        List<Baseline_Health_Overview__c> recordsToUpdate = [
            SELECT Id
            FROM Baseline_Health_Overview__c
            WHERE Lead__c = :leadId
        ];

        for (Baseline_Health_Overview__c record : recordsToUpdate) {
            record.Account__c = accountId;
        }

        if (!recordsToUpdate.isEmpty()) {
            update recordsToUpdate;
        }
    }

   @TestVisible private static void updatePharmacy(Id leadId, Id accountId) {
        List<Pharmacy_Location__c> recordsToUpdate = [
            SELECT Id
            FROM Pharmacy_Location__c
            WHERE Lead__c = :leadId
        ];

        for (Pharmacy_Location__c record : recordsToUpdate) {
            record.Account__c = accountId;
        }

        if (!recordsToUpdate.isEmpty()) {
            update recordsToUpdate;
        }
    }

   @TestVisible private static void updateBaselineResponse(Id leadId, Id accountId, Id caseId) {
        List<Baseline_Response__c> recordsToUpdate = [
            SELECT Id
            FROM Baseline_Response__c
            WHERE Lead__c = :leadId
        ];

        for (Baseline_Response__c recordBr : recordsToUpdate) {
            recordBr.Account__c = accountId;
            recordBr.Case__c = caseId;
        }

        if (!recordsToUpdate.isEmpty()) {
            update recordsToUpdate;
        }
    }

    @TestVisible private static void updateStripe(Id leadId, Id accountId) {
        List<Stripe_Payments_Logs__c> recordsToUpdate = [
            SELECT Id
            FROM Stripe_Payments_Logs__c
            WHERE Lead__c = :leadId
        ];

        for (Stripe_Payments_Logs__c record : recordsToUpdate) {
            record.Account__c = accountId;
        }

        if (!recordsToUpdate.isEmpty()) {
            update recordsToUpdate;
        }
    }

    @TestVisible private static void updateConsent(Id leadId, Id accountId) {
        List<Consent_Logs__c> recordsToUpdate = [
            SELECT Id
            FROM Consent_Logs__c
            WHERE Lead__c = :leadId
        ];

        for (Consent_Logs__c record : recordsToUpdate) {
            record.Account__c = accountId;
        }

        if (!recordsToUpdate.isEmpty()) {
            update recordsToUpdate;
        }
    }
    
    @TestVisible private static void updateMedicalCondition(Id leadId, Id accountId) {
        List<Medical_Condition__c> conditionsToUpdate = [
            SELECT Id
            FROM Medical_Condition__c
            WHERE Lead__c = :leadId
        ];

        for (Medical_Condition__c condition : conditionsToUpdate) {
            condition.Account__c = accountId;
        }

        if (!conditionsToUpdate.isEmpty()) {
            update conditionsToUpdate;
        }
    }

    // Helper method to update Opportunity records
   @TestVisible private static void updateOpportunity(Id leadId, Id accountId) {
        List<Opportunity> opportunitiesToUpdate = [
            SELECT Id
            FROM Opportunity
            WHERE Lead__c = :leadId
        ];

        for (Opportunity opportunity : opportunitiesToUpdate) {
            opportunity.AccountId = accountId;
        }

        if (!opportunitiesToUpdate.isEmpty()) {
            update opportunitiesToUpdate;
        }
    }
    @TestVisible private static void moveFilesToAccount(Id leadId, Id accountId, Id caseId) {
        List<ContentDocumentLink> filesToMove = [
            SELECT Id, ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :leadId
        ];
        List<ContentVersion> newVersionsForAccount = new List<ContentVersion>();
        List<ContentVersion> newVersionsForCase = new List<ContentVersion>();

        for (ContentDocumentLink file : filesToMove) {
            // Query the ContentVersion related to the ContentDocumentId
            ContentVersion originalVersion = [
                SELECT Id, Title, PathOnClient, VersionData, SharingPrivacy
                FROM ContentVersion
                WHERE ContentDocumentId = :file.ContentDocumentId
                LIMIT 1
            ];

            if (originalVersion != null) {
                // Create a new ContentVersion for the Account
                ContentVersion newVersionForAccount = new ContentVersion(
                    Title = originalVersion.Title,
                    PathOnClient = originalVersion.PathOnClient,
                    VersionData = originalVersion.VersionData,
                    SharingPrivacy = originalVersion.SharingPrivacy,
                    FirstPublishLocationId = accountId
                );
                newVersionsForAccount.add(newVersionForAccount);

                // Create a new ContentVersion for the Case
                ContentVersion newVersionForCase = new ContentVersion(
                    Title = originalVersion.Title,
                    PathOnClient = originalVersion.PathOnClient,
                    VersionData = originalVersion.VersionData,
                    SharingPrivacy = originalVersion.SharingPrivacy,
                    FirstPublishLocationId = caseId
                );
                newVersionsForCase.add(newVersionForCase);
            }
        }

        if (!newVersionsForAccount.isEmpty()) {
            insert newVersionsForAccount;
        }

        if (!newVersionsForCase.isEmpty()) {
            insert newVersionsForCase;
        }
    }
}