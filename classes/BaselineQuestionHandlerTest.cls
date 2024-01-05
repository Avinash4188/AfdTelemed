@isTest
private class BaselineQuestionHandlerTest {

    @TestSetup
    static void setup() {
        
        //Create a test Lead
        Lead testLead = new Lead();
        testLead.FirstName = 'John';
        testLead.LastName = 'Doe';
        testLead.Email = 'test@example.com';
        testLead.Company = 'Test Company';
        insert testLead; 
    }
    
    static testmethod List<BaselineWrapper> testgetQuestionsAndResponsesByMedicalCondition() {
        
         Lead testLead = [SELECT Id,FirstName,LastName,Email,Company FROM Lead WHERE LastName ='Doe' LIMIT 1];
        Medical_Condition__c mc = new Medical_Condition__c();
        mc.Lead__c = testLead.Id;
        mc.List_Of_Medical_Condition__c = 'ADHD';
        Insert mc;
        
        Baseline_Question__c bq = new Baseline_Question__c();
        //SELECT Id, Question__c, Response_Field_Type__c, Response_Field_Values__c, Sort_Order__c, List_Of_Medical_Condition__c, Is_Additional_Information__c, Additional_Information_field_Type__c FROM Baseline_Question__c
        bq.Question__c = 'Q-0010';
        bq.Response_Field_Type__c = 'text';
        bq.Response_Field_Values__c= 'test';
        bq.Sort_Order__c = 1;
        bq.List_Of_Medical_Condition__c = mc.List_Of_Medical_Condition__c;
        bq.Is_Additional_Information__c = true;
        bq.Additional_Information_field_Type__c = 'date';
        Insert bq;
        
        //SELECT Id, Response__c, Baseline_Question__c, Additional_Information__c, Lead__c, Sort_Order__c FROM Baseline_Response__c ORDER BY Sort_Order__c
        Baseline_Response__c br = new Baseline_Response__c();
        br.Response__c = 'Test Response';
        br.Lead__c = testLead.Id;
        br.Baseline_Question__c =bq.Id ;
        br.Additional_Information__c = 'Test information';
        //br.Sort_Order__c = 1;
        Insert br;
        
        Test.StartTest();
        List<BaselineWrapper> result = BaselineQuestionHandler.getQuestionsAndResponsesByMedicalCondition(testLead.Id);
        Test.StopTest();
        System.assertNotEquals(Null,result.size());
        System.assertEquals(result[0].LeadId,testLead.Id);
        System.assertEquals(result[0].responseId,br.Id);
        System.assertEquals(result[0].questionId, bq.Id);
        System.assertEquals('ADHD',mc.List_Of_Medical_Condition__c);
        System.assertEquals('ADHD',bq.List_Of_Medical_Condition__c);
        return result;
    }
    
    static testmethod List<Id> testsaveResponses() {
     
        Lead testLead = [SELECT Id,FirstName,LastName,Email,Company FROM Lead WHERE LastName ='Doe' LIMIT 1];
        
        // Create test data
        List<Map<String, Object>> responsesInputList = new List<Map<String, Object>>();
        
        Baseline_Question__c bq = new Baseline_Question__c();
        //SELECT Id, Question__c, Response_Field_Type__c, Response_Field_Values__c, Sort_Order__c, List_Of_Medical_Condition__c, Is_Additional_Information__c, Additional_Information_field_Type__c FROM Baseline_Question__c
        bq.Question__c = 'Q-0010';
        bq.Response_Field_Type__c = 'text';
        bq.Response_Field_Values__c= 'test';
        bq.Sort_Order__c = 1;
        bq.List_Of_Medical_Condition__c = 'ADHD';
        bq.Is_Additional_Information__c = true;
        bq.Additional_Information_field_Type__c = 'date';
        Insert bq;
        
        // Add test data to responsesInputList
        Map<String, Object> response1 = new Map<String, Object>{
            'Baseline_Question__c' => bq.Id, 
            'Response__c' => 'Test Response 1',
            'lead__c' => testLead.Id, 
            'Additional_Information__c' => 'Additional info for response 1'
        };
        responsesInputList.add(response1);
        
        Map<String, Object> response2 = new Map<String, Object>{
            'Baseline_Question__c' => bq.Id, 
            'Response__c' => 'Test Response 2',
            'lead__c' => testLead.Id, 
            'Additional_Information__c' => 'Additional info for response 2'
        };
        responsesInputList.add(response2);
        
        // Call the method
        Test.startTest();
        List<Id> savedIds = BaselineQuestionHandler.saveResponses(responsesInputList);
        Test.stopTest();
        
        // Check if the records were saved and have valid Ids
        System.assertEquals(2, savedIds.size());
        for (Id savedId : savedIds) {
            System.assertNotEquals(null, savedId);
        }
        
        return savedIds;
    }
}