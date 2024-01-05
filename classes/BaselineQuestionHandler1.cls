public without sharing class BaselineQuestionHandler1 {
    
    @AuraEnabled(cacheable=true)
    public static List<Baseline_Question__c> getQuestionsAndResponsesByMedicalCondition(String medicalCondition) {
        return [SELECT Id, Question__c, Response_Field_Type__c, Response_Field_Values__c, Sort_Order__c, List_Of_Medical_Condition__c
                FROM Baseline_Question__c
                WHERE List_Of_Medical_Condition__c = :medicalCondition
                ORDER BY Sort_Order__c];
    }

    @AuraEnabled
    public static void saveResponses(List<Baseline_Response__c> responses) {
        if (responses != null && !responses.isEmpty()) {
            upsert responses;
        }
    }
}