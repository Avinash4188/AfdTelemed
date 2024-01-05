public without sharing class BaselineQuestionPortalHandler {
    @AuraEnabled
    public static List<BaselineWrapper> getQuestionsAndResponsesByMedicalCondition(String accountId) {
        
        Opportunity oppData = [SELECT Id FROM Opportunity WHERE AccountId = :accountId AND StageName != 'Closed Won' LIMIT 1];
        system.debug(oppData.Id);
        // Query for the medical condition based on the Lead ID
        List<Medical_Condition__c> medicalConditions = [SELECT List_Of_Medical_Condition__c 
                                                        FROM Medical_Condition__c 
                                                        WHERE Opportunity__c = :oppData.Id 
                                                        LIMIT 1]; // Use LIMIT 1 to ensure only one value is returned
        
        List<BaselineWrapper> result = new List<BaselineWrapper>();
        
        String medicalCondition = null; // Initialize the medicalCondition variable
        
        // Check if a medical condition record was found
        if (!medicalConditions.isEmpty()) {
            medicalCondition = medicalConditions[0].List_Of_Medical_Condition__c;
        }
        
        // Retrieve questions by medical condition
        List<Baseline_Question__c> questions = [SELECT Id, Question__c, Response_Field_Type__c, Response_Field_Values__c, Sort_Order__c, List_Of_Medical_Condition__c, Is_Additional_Information__c, Additional_Information_field_Type__c
                                                FROM Baseline_Question__c
                                                WHERE List_Of_Medical_Condition__c = :medicalCondition
                                                ORDER BY Sort_Order__c];
        
        // Retrieve responses by medical condition
        List<Baseline_Response__c> responses = [SELECT Id, Response__c, Baseline_Question__c, Additional_Information__c, Account__c, Sort_Order__c, Opportunity__c
                                                FROM Baseline_Response__c WHERE Opportunity__c = :oppData.Id
                                                ORDER BY Sort_Order__c];
        
        // Merge questions and responses into the result list
        for (Baseline_Question__c question : questions) {
            BaselineWrapper wrapper = new BaselineWrapper();
            wrapper.questionId = question.Id;
            wrapper.question = question.Question__c;
            wrapper.responseFieldType = question.Response_Field_Type__c;
            wrapper.responseFieldValues = question.Response_Field_Values__c;
            wrapper.sortOrder = integer.valueOf(question.Sort_Order__c);
            wrapper.medicalCondition = question.List_Of_Medical_Condition__c;
            wrapper.isAdditionalInformation = Boolean.valueOf(question.Is_Additional_Information__c);
            wrapper.additionalInformationFieldType = question.Additional_Information_field_Type__c;
            result.add(wrapper);
        }
        
        for (Baseline_Response__c response : responses) {
            for (BaselineWrapper wrapper : result) {
                if (response.Baseline_Question__c == wrapper.questionId) {
                    wrapper.responseId = response.Id;
                    wrapper.response = response.Response__c;
                    wrapper.additionalInformation = response.Additional_Information__c;
                    wrapper.opportunityId = response.Opportunity__c;
                    wrapper.accountId = response.Account__c;
                    break;
                }
            }
        }
        
        return result;
    }
    
    @AuraEnabled
    public static List<Id> saveResponses(List<Map<String, Object>> responsesInputList) {
        List<Id> savedIds = new List<Id>();
        List<Baseline_Response__c> recordsToUpsert = new List<Baseline_Response__c>();
        
        try {
            for (Map<String, Object> responsesInput : responsesInputList) {
                Id opportunityId;
                List<Opportunity> opportunities = [SELECT Id FROM Opportunity WHERE AccountId = :(Id)responsesInput.get('account__c') AND StageName != 'Closed Won' LIMIT 1];
                if (!opportunities.isEmpty()) {
                    opportunityId = opportunities[0].Id;
                }

                Baseline_Response__c responseNew = new Baseline_Response__c();
                responseNew.Baseline_Question__c = (Id)responsesInput.get('Baseline_Question__c');
                responseNew.Response__c = (String)responsesInput.get('Response__c');
                responseNew.Account__c = (Id)responsesInput.get('account__c');
                responseNew.Opportunity__c = opportunityId;
                responseNew.Additional_Information__c = (String)responsesInput.get('Additional_Information__c');

                System.debug(responseNew);

                recordsToUpsert.add(responseNew);
            }
            
            upsert recordsToUpsert;
            
            for (Baseline_Response__c savedRecord : recordsToUpsert) {
                savedIds.add(savedRecord.Id);
            }
        } catch (Exception ex) {
            throw new AuraHandledException('Error saving responses: ' + ex.getMessage());
        }
        
        return savedIds;
    }
    /**
@AuraEnabled
public static List<Id> saveFiles(List<Map<String, Object>> formData) {
List<Id> contentVersionIds = new List<Id>();
System.debug('formData:'+formData);

try {
for (Map<String, Object> form : formData) {
Id leadId = (Id) form.get('leadId');
Id questionId = (Id) form.get('questionId');
List<ContentVersion> contentVersions = new List<ContentVersion>();
List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();

for (Map<String, Object> file : (List<Map<String, Object>>) form.get('files')) {
String fileName = (String) file.get('name');
String base64Data = (String) file.get('base64Data');
system.debug('base64Data'+base64Data);

// Convert base64 data to Blob
Blob fileBlob = EncodingUtil.base64Decode(base64Data);


// Create ContentVersion record
ContentVersion contentVersion = new ContentVersion();
contentVersion.Title = fileName;
contentVersion.VersionData = fileBlob;
contentVersions.add(contentVersion);
}

// Insert ContentVersions
insert contentVersions;
System.debug('contentVersions:'+contentVersions);

// Create ContentDocumentLinks to associate files with the lead and question
for (ContentVersion cv : contentVersions) {
ContentDocumentLink cdl = new ContentDocumentLink();
cdl.ContentDocumentId = cv.ContentDocumentId;
cdl.LinkedEntityId = questionId; // Assuming you want to link it to the question
cdl.ShareType = 'I'; // Inferred permission
cdl.Visibility = 'AllUsers';
contentDocumentLinks.add(cdl);
}

// Insert ContentDocumentLinks
insert contentDocumentLinks;
System.debug('contentDocumentLinks:'+contentDocumentLinks);

// Add the ContentVersion Ids to the list to return
for (ContentVersion cv : contentVersions) {
contentVersionIds.add(cv.Id);
}
}

return contentVersionIds;
} catch (Exception e) {
// Handle exceptions here
System.debug('Error saving files: ' + e.getMessage());
return null;
}
}**/
}