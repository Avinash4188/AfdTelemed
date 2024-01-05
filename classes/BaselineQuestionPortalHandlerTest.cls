@isTest
Private class BaselineQuestionPortalHandlerTest {
    
    @TestSetup
    static void setData(){
        
        //Create a test Account
        Account a = new Account();
        a.Name ='Test Company';
        insert a;
        
        //Create a test Opportunity
        Opportunity opp = new Opportunity();
        opp.AccountId = a.Id;
        opp.Name = a.Name;
        opp.StageName ='Prospecting';
        opp.CloseDate = System.today();
        insert opp;
        
         // Create a test Medical_Condition__c
       Medical_Condition__c mc = new Medical_Condition__c();
       mc.Opportunity__c = opp.Id;
       mc.List_Of_Medical_Condition__c = 'Acne';
       Insert mc;
        
        //create a test Baseline_Question__c
        Baseline_Question__c bq = new Baseline_Question__c();
        bq.Question__c = 'When did your symptoms start?';
        bq.Response_Field_Type__c = 'text';
        bq.Response_Field_Values__c= 'test';
        bq.Sort_Order__c = 1;
        bq.List_Of_Medical_Condition__c = mc.List_Of_Medical_Condition__c;
        bq.Is_Additional_Information__c = true;
        bq.Additional_Information_field_Type__c = 'date';
        Insert bq;
        
        Baseline_Response__c br = new Baseline_Response__c();
        br.Response__c = 'Test Response';
        br.Account__c = a.Id;
        br.Opportunity__c = opp.Id;
        br.Baseline_Question__c =bq.Id ;
        br.Additional_Information__c = 'Test information';
        //br.Sort_Order__c = bq.Sort_Order__c;
        Insert br;
    }
    
    @isTest
    static List<BaselineWrapper> testgetQuestionsAndResponsesByMedicalCondition() {
        
        Account acc = [SELECT Id,Name FROM Account WHERE Name='Test Company' LIMIT 1];      
        Opportunity opp = [SELECT Id,Name FROM Opportunity WHERE AccountId =: acc.Id LIMIT 1]; 
        Medical_Condition__c mc = [SELECT Id,Opportunity__c,List_Of_Medical_Condition__c FROM Medical_Condition__c WHERE Opportunity__c = :opp.Id LIMIT 1];
        
         List<Baseline_Question__c> questions = [SELECT Id, Question__c, Response_Field_Type__c, Response_Field_Values__c, Sort_Order__c, List_Of_Medical_Condition__c, Is_Additional_Information__c, Additional_Information_field_Type__c
                                                FROM Baseline_Question__c WHERE List_Of_Medical_Condition__c = :mc.List_Of_Medical_Condition__c 
                                                 ORDER BY Sort_Order__c];
          List<Baseline_Response__c> responses = [SELECT Id, Response__c, Baseline_Question__c, Additional_Information__c, Account__c, Sort_Order__c, Opportunity__c
                                                FROM Baseline_Response__c WHERE Opportunity__c = :opp.Id ORDER BY Sort_Order__c];
        
        Test.StartTest();
       List<BaselineWrapper> testResult =  BaselineQuestionPortalHandler.getQuestionsAndResponsesByMedicalCondition(acc.Id);
        Test.StopTest();
        System.assertNotEquals(Null,testResult);
        System.assertEquals('Acne',questions[0].List_Of_Medical_Condition__c);
        System.assertEquals(opp.Id,responses[0].Opportunity__c);
        
        return testResult;
    }
    
    @isTest
    static List<Id> testsaveResponses() {
         Test.StartTest();
        Account acc = [SELECT Id,Name FROM Account WHERE Name='Test Company' LIMIT 1]; 
         Opportunity opp = [SELECT Id,Name FROM Opportunity WHERE AccountId =:acc.Id LIMIT 1]; 
        Baseline_Question__c questions = [SELECT Id, Question__c, Response_Field_Type__c, Response_Field_Values__c, Sort_Order__c, Is_Additional_Information__c, Additional_Information_field_Type__c
                                                FROM Baseline_Question__c LIMIT 1];
        Map<string,Object> maps = new Map<string,Object>{
        'Baseline_Question__c' => questions.Id,
        'Response__c' => 'Test Response',
        'Account__c' => acc.Id,
        'opportunity__c' => Opp.Id,
        'Additional_Information__c' => 'Test information'
            };
                List<Opportunity> oppList = [SELECT Id,Name FROM Opportunity WHERE AccountId =:(Id)maps.get(acc.Id) LIMIT 1];
                List<Map<String, Object>> responsesInputList = new List<Map<String, Object>>{maps};
      
        List<Id> savedIds = BaselineQuestionPortalHandler.saveResponses(responsesInputList);
       System.debug('*********' + savedIds);
        System.assertNotEquals(Null,savedIds);
        
        Baseline_Response__c SavedResponses = [SELECT Id, Response__c, Baseline_Question__c, Additional_Information__c,Account__c, Opportunity__c
                                                FROM Baseline_Response__c LIMIT 1];
        System.debug('*****SavedResponses' + SavedResponses);
        System.debug('Account' + SavedResponses.Account__c);
        System.debug('Opportunity' + SavedResponses.Opportunity__c);
        system.assertEquals(questions.Id, SavedResponses.Baseline_Question__c);
        system.assertEquals('Test Response', SavedResponses.Response__c);
        system.assertEquals(acc.Id, SavedResponses.Account__c);
        system.assertEquals(opp.Id, SavedResponses.Opportunity__c);
        system.assertEquals('Test information', SavedResponses.Additional_Information__c);
         Test.StopTest();
        return savedIds;
    }
}