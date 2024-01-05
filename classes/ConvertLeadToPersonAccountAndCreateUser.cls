public without sharing class ConvertLeadToPersonAccountAndCreateUser implements Queueable {
    
    @TestVisible private String leadId;
    
    public ConvertLeadToPersonAccountAndCreateUser(String leadId) {
        this.leadId = leadId;
    }
    
    public void execute(QueueableContext context) {
        try {
            // Query all fields from the Lead
            Lead leadRecord = [SELECT Id, FirstName, LastName, Email FROM Lead WHERE Id = :leadId LIMIT 1];
            
            // Check if the Lead exists
            if (leadRecord != null) {
                // Convert the Lead to a Person Account
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(leadRecord.Id);
                lc.setDoNotCreateOpportunity(true); // You can modify this based on your requirements
                lc.setAccountId(null); // To create a new Person Account
                lc.setConvertedStatus('Qualified'); // You can set the desired status
                Database.LeadConvertResult lcr = Database.convertLead(lc);
                
                System.debug('lcr:'+lcr);
                Id convertedAccountId = lcr.getAccountId();
                
                if (lcr.isSuccess()) {
                    RecordType recotdType = [Select Id,NAme, DeveloperName from RecordType  where SobjectType = 'Account' and DeveloperName = 'PersonAccount' LIMIT 1];
                    Account accountToUpdate = new Account(Id = convertedAccountId);
                    accountToUpdate.RecordTypeId = recotdType.Id;
                    update accountToUpdate;
                    // Define username, password, and community ID
                    String username = leadRecord.Email;
                    
                    System.debug('username:'+username);
                    
                    User profileId = [Select ProfileId from User where Profile.Name = 'Patient' LIMIT 1];
                    
                    // Create a new User
                    User newUser = new User(
                        FirstName = leadRecord.FirstName,
                        LastName = leadRecord.LastName,
                        ContactId = lcr.getContactId(),
                        Username = username,
                        Email = leadRecord.Email,
                        CommunityNickname = username,
                        Alias = username.substring(0, 8),
                        TimeZoneSidKey = 'GMT',
                        LocaleSidKey = 'en_US',
                        EmailEncodingKey = 'UTF-8',
                        ProfileId = profileId.ProfileId,
                        LanguageLocaleKey = 'en_US',
                        IsActive = true
                    );
                    System.debug('newUserBefore:'+newUser);
                    
                    // Insert the new User record
                    insert newUser;
                    System.debug('newUserAfter:'+newUser);
                    
                    //Call new method for Segeration of data lead to Account
                    
                    leadData(leadId, convertedAccountId);
                    
                } else {
                    // Handle the Lead conversion failure here
                    System.debug('Lead conversion failed: ' + lcr.getErrors()[0].getMessage());
                }
            } else {
                // Handle the case where the Lead does not exist
                System.debug('Lead with ID ' + leadId + ' does not exist.');
            }
        } catch (Exception e) {
            // Handle any exceptions that may occur
            System.debug('An error occurred: ' + e.getMessage());
        }
    }
    public static void leadData(String leadId, String accountId) {
        updateMedicalCondition(leadId, accountId);
        updateLabTest(leadId, accountId);
        try { 
            Case recordType = [Select RecordTypeId from Case where RecordType.Name = 'Initial Patient Visit' LIMIT 1];
            Account accountEmail = [Select Id, Name, PersonEmail from Account where Id= :accountId LIMIT 1];
            List<Medical_Condition__c> existingconditionValue = [SELECT Id, List_Of_Medical_Condition__c FROM Medical_Condition__c WHERE Account__c = :accountId LIMIT 1];
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
                List<Labs_Tests__c> existinglabValue = [SELECT Id, Labs_Tests__c FROM Labs_Tests__c WHERE Account__c = :accountId LIMIT 1];
                Case newCase = New Case();
                newCase.AccountId = accountId;
                newCase.Subject = accountEmail.Name+' '+date.today();
                newCase.Status = 'New Patient';
                newCase.Origin = 'Web';
                newCase.Labs_Tests__c = existinglabValue[0].Id;
                newCase.SuppliedEmail = accountEmail.PersonEmail;
                newCase.RecordTypeId = recordType.RecordTypeId;
                insert newCase;
                System.debug('An lab occurred for Case: ');
            }
            
        } catch (Exception e) {
            // Handle any exceptions that may occur
            System.debug('An error occurred for Case: ' + e.getMessage());
        }
        case caseID = [Select id from case where AccountId = :accountId LIMIT 1];
        updateBaselineHealthOverview(leadId, accountId);
        updatePharmacy(leadId, accountId);
        updateBaselineResponse(leadId, accountId, caseID.Id);
        updateStripe(leadId, accountId);
        updateConsent(leadId, accountId);
        moveFilesToAccount(leadId, accountId, caseID.Id);
        
        updateOpportunity(leadId, accountId);
        
        // Retrieve State value from Lead
        Lead leadRecord = [SELECT Id, State__c FROM Lead WHERE Id = :leadId LIMIT 1];
        String leadState = leadRecord.State__c;
        
        // Update State field in related Account
        Account accountToUpdate = new Account(Id = accountId);
        accountToUpdate.State__c = leadState;
        
        if (leadState == 'District of Columbia' || leadState == 'New Hampshire' || leadState == 'Mississippi' || leadState == 'Idaho') {
            accountToUpdate.Video_Call__c = 'Pending';
        }
        
        update accountToUpdate;
        
        
        
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
    @TestVisible private static void updateLabTest(Id leadId, Id accountId) {
        List<Labs_Tests__c> conditionsToUpdate = [
            SELECT Id
            FROM Labs_Tests__c
            WHERE Lead__c = :leadId
        ];
        
        for (Labs_Tests__c condition : conditionsToUpdate) {
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