public class BaselineWrapper {
    @AuraEnabled public String questionId { get; set; }
    @AuraEnabled public String question { get; set; }
    @AuraEnabled public Boolean isAdditionalInformation { get; set; }
    @AuraEnabled public String additionalInformationFieldType { get; set; }
    @AuraEnabled public String responseFieldType { get; set; }
    @AuraEnabled public String responseFieldValues { get; set; }
    @AuraEnabled public Integer sortOrder { get; set; }
    @AuraEnabled public String medicalCondition { get; set; }
    @AuraEnabled public String responseId { get; set; }
    @AuraEnabled public String response { get; set; }
    @AuraEnabled public String additionalInformation { get; set; }
    @AuraEnabled public String leadId { get; set; }
    @AuraEnabled public String accountId { get; set; }
    @AuraEnabled public String opportunityId { get; set; }
    
    public BaselineWrapper(){
        
    }
}