public without sharing class finalPortalSubmit {
    @AuraEnabled
    public static void leadData(String accountId) {
        opportunity opportunityID = [SELECT Id FROM Opportunity WHERE AccountId = :accountId AND StageName != 'Closed Won' LIMIT 1];
        try { 
            Case recordType = [Select RecordTypeId from Case where RecordType.Name = 'Initial Patient Visit' LIMIT 1];
            Account accountEmail = [Select Id, Name, PersonEmail from Account where Id= :accountId LIMIT 1];
            List<Medical_Condition__c> existingconditionValue = [SELECT Id, List_Of_Medical_Condition__c FROM Medical_Condition__c WHERE Account__c = :accountId AND Opportunity__c = :opportunityID.Id LIMIT 1];
            if (!existingconditionValue.isEmpty()) {
                Case newCase = New Case();
                newCase.AccountId = accountId;
                newCase.Subject = existingconditionValue[0].List_Of_Medical_Condition__c + ': '+accountEmail.Name+' '+date.today();
                newCase.Medical_Conditions__c = existingconditionValue[0].Id;
                newCase.Status = 'New Patient';
                newCase.Origin = 'Web';
                newCase.SuppliedEmail = accountEmail.PersonEmail;
                newCase.RecordTypeId = recordType.RecordTypeId;
                insert newCase;
                System.debug('An medical occurred for Case: ');
            } else {
                Case newCase = New Case();
                newCase.AccountId = accountId;
                newCase.Subject = accountEmail.Name+' '+date.today();
                //newCase.Medical_Conditions__c = existingconditionValue[0].Id;
                newCase.Status = 'New Patient';
                newCase.Origin = 'Web';
                newCase.SuppliedEmail = accountEmail.PersonEmail;
                newCase.RecordTypeId = recordType.RecordTypeId;
                insert newCase;
                System.debug('An lab occurred for Case: ');
            }
            
        } catch (Exception e) {
            // Handle any exceptions that may occur
            System.debug('An error occurred for Case: ' + e.getMessage());
        }
        case caseID = [Select id from case where AccountId = :accountId ORDER BY CreatedDate DESC LIMIT 1];
        if (opportunityID != null) {
            opportunityID.StageName = 'Closed Won';
            update opportunityID;
        }
        
        updateBaselineResponse(opportunityID.Id, accountId, caseID.Id);
        updateStripe(opportunityID.Id, accountId);
        moveFilesToAccount(opportunityID.Id, accountId, caseID.Id);
    }
    @TestVisible private static void updateBaselineResponse(Id opportunityId, Id accountId, Id caseId) {
        List<Baseline_Response__c> recordsToUpdate = [
            SELECT Id
            FROM Baseline_Response__c
            WHERE Opportunity__c = :opportunityId
        ];
        
        for (Baseline_Response__c recordBr : recordsToUpdate) {
            recordBr.Account__c = accountId;
            recordBr.Case__c = caseId;
        }
        
        if (!recordsToUpdate.isEmpty()) {
            update recordsToUpdate;
        }
    }
    @TestVisible private static void updateStripe(Id opportunityId, Id accountId) {
        List<Stripe_Payments_Logs__c> recordsToUpdate = [
            SELECT Id
            FROM Stripe_Payments_Logs__c
            WHERE Opportunity__c = :opportunityId
        ];
        
        for (Stripe_Payments_Logs__c record : recordsToUpdate) {
            record.Account__c = accountId;
        }
        
        if (!recordsToUpdate.isEmpty()) {
            update recordsToUpdate;
        }
    }
    @TestVisible private static void moveFilesToAccount(Id opportunityId, Id accountId, Id caseId) {
        List<ContentDocumentLink> filesToMove = [
            SELECT Id, ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :opportunityId
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