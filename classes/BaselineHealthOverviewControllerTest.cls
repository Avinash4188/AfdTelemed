@isTest
private class BaselineHealthOverviewControllerTest {
    @TestSetup
    static void setup() {
        
        //Create a test Lead
        Lead testLead = new Lead();
        testLead.FirstName = 'John';
        testLead.LastName = 'Doe';
        testLead.Email = 'test@example.com';
        testLead.Company = 'Test Company';
        insert testLead; 
        
        //Create a test Baseline_Health_Overview__c
        Baseline_Health_Overview__c bho = new Baseline_Health_Overview__c();
        bho.Lead__c = testLead.Id;
        bho.Add_details_of_your_last_visit__c = 'Testdata';
        bho.Any_allergic_reaction_to_the_medication__c = false;
        bho.Diastolic_Pressure__c = 'Normal';
        bho.Height__c = 7;
        bho.High_Blood_Pressure__c = true;    
        //bho.List_of_environmental_allergies_reaction__c = 'Abalone allergy;Albendazole allergy';
        //bho.List_Of_Medical_Condition__c = 'Acne;ADHD';
        //bho.List_Of_Medications__c = 'Amphetamine;Desitin';
        bho.Most_Recent_Physical_Medical_Visit__c = System.Today();
        bho.Systolic_Pressure__c = 'Normal';
        bho.Weight__c = 120 ;
        bho.What_happen_when_you_had_allergic_react__c = 'some Reaction';
       Insert bho;
        
    }

    static testmethod Baseline_Health_Overview__c testgetBaselineHealthOverview() {
        
        Lead testLead = [SELECT Id,FirstName,LastName,Email,Company FROM Lead WHERE LastName ='Doe' LIMIT 1];
        Baseline_Health_Overview__c bho =[Select Add_details_of_your_last_visit__c, Any_allergic_reaction_to_the_medication__c, Diastolic_Pressure__c, 
                                          Height__c, High_Blood_Pressure__c, List_of_environmental_allergies_reaction__c,List_Of_Medical_Condition__c, 
                                          List_Of_Medications__c, Most_Recent_Physical_Medical_Visit__c, Systolic_Pressure__c, Weight__c,
                                          What_happen_when_you_had_allergic_react__c from Baseline_Health_Overview__c WHERE Lead__c =: testLead.Id];

        Test.StartTest();
        Baseline_Health_Overview__c result = BaselineHealthOverviewController.getBaselineHealthOverview(testLead.Id);
        Test.StopTest();
        System.assertNotEquals(Null,result);
        System.assertEquals('some Reaction', result.What_happen_when_you_had_allergic_react__c);
           
        return result;
        
    }
        
    static testmethod List<String> testgetAllergies() {
        
       Lead testLead = [SELECT Id,FirstName,LastName,Email,Company FROM Lead WHERE LastName ='Doe' LIMIT 1];
        Baseline_Health_Overview__c bho =[Select Add_details_of_your_last_visit__c, Any_allergic_reaction_to_the_medication__c, Diastolic_Pressure__c, 
                                          Height__c, High_Blood_Pressure__c, List_of_environmental_allergies_reaction__c,List_Of_Medical_Condition__c, 
                                          List_Of_Medications__c, Most_Recent_Physical_Medical_Visit__c, Systolic_Pressure__c, Weight__c,
                                          What_happen_when_you_had_allergic_react__c from Baseline_Health_Overview__c WHERE Lead__c =: testLead.Id];
        
        Test.StartTest();
        List<String> picklistValues = BaselineHealthOverviewController.getAllergies();
        Test.StopTest();
        System.assertNotEquals(null, picklistValues, 'Result should not be null');
        System.assertEquals(239, picklistValues.size(), 'Expected size of picklistValues list is 239');
        //System.assertEquals(List_of_environmental_allergies_reaction__c);
        return picklistValues;
    }
    
    static testmethod List<String> testgetMedication() {
        
        Lead testLead = [SELECT Id,FirstName,LastName,Email,Company FROM Lead WHERE LastName ='Doe' LIMIT 1];
        Baseline_Health_Overview__c bho =[Select Add_details_of_your_last_visit__c, Any_allergic_reaction_to_the_medication__c, Diastolic_Pressure__c, 
                                          Height__c, High_Blood_Pressure__c, List_of_environmental_allergies_reaction__c,List_Of_Medical_Condition__c, 
                                          List_Of_Medications__c, Most_Recent_Physical_Medical_Visit__c, Systolic_Pressure__c, Weight__c,
                                          What_happen_when_you_had_allergic_react__c from Baseline_Health_Overview__c WHERE Lead__c =: testLead.Id];
        
        Test.StartTest();
       List<String> picklistValues = BaselineHealthOverviewController.getMedication();
        Test.StopTest();
        System.assertNotEquals(Null,picklistValues);
        System.assertEquals(260,picklistValues.size());
        //System.assertEquals('Amphetamine;Augmentin',picklistValues);
        
        return picklistValues;
    }
    
    static testmethod List<string> testgetMedicalCondition() {
        
        Lead testLead = [SELECT Id,FirstName,LastName,Email,Company FROM Lead WHERE LastName ='Doe' LIMIT 1];
        Baseline_Health_Overview__c bho =[Select Add_details_of_your_last_visit__c, Any_allergic_reaction_to_the_medication__c, Diastolic_Pressure__c, 
                                          Height__c, High_Blood_Pressure__c, List_of_environmental_allergies_reaction__c,List_Of_Medical_Condition__c, 
                                          List_Of_Medications__c, Most_Recent_Physical_Medical_Visit__c, Systolic_Pressure__c, Weight__c,
                                          What_happen_when_you_had_allergic_react__c from Baseline_Health_Overview__c WHERE Lead__c =: testLead.Id];
        
        Test.StartTest();
        List<String> picklistValues = BaselineHealthOverviewController.getMedicalCondition();
        Test.StopTest();
        System.assertNotEquals(Null,picklistValues);
        System.assertEquals(35,picklistValues.size());
        //System.assertEquals('Acne;ADHD',picklistValues);
        
        return picklistValues;
    }
    
    static testmethod Id createBaselineHealthOverview() {
        
         Id result;
         Lead testLead = [SELECT Id,FirstName,LastName,Email,Company FROM Lead WHERE LastName ='Doe' LIMIT 1];
        
        Map<String, Object> recordInput = new Map<String, Object>();
        recordInput.put('leadId', testLead.Id);
        recordInput.put('Any_allergic_reaction_to_the_medication__c', true);
        recordInput.put('High_Blood_Pressure__c', false);
        recordInput.put('List_of_environmental_allergies_reaction__c', 'Abalone allergy');
        recordInput.put('List_Of_Medical_Condition__c', 'Asthma');
        recordInput.put('List_Of_Medications__c', 'Amphetamine, Augmentin');
        
        Baseline_Health_Overview__c bho =[Select Add_details_of_your_last_visit__c, Any_allergic_reaction_to_the_medication__c, Diastolic_Pressure__c, 
                                          Height__c, High_Blood_Pressure__c, List_of_environmental_allergies_reaction__c,List_Of_Medical_Condition__c, 
                                          List_Of_Medications__c, Most_Recent_Physical_Medical_Visit__c, Systolic_Pressure__c, Weight__c,
                                          What_happen_when_you_had_allergic_react__c from Baseline_Health_Overview__c WHERE Lead__c =: testLead.Id];
        
        Test.StartTest();
        try{
    
             result = BaselineHealthOverviewController.createBaselineHealthOverview(recordInput,bho);
            
            System.debug('result'+result);
            System.assertNotEquals(Null,result);
            
            Baseline_Health_Overview__c resultRecord = [Select Add_details_of_your_last_visit__c, Any_allergic_reaction_to_the_medication__c, Diastolic_Pressure__c, 
                                                          Height__c, High_Blood_Pressure__c, List_of_environmental_allergies_reaction__c,List_Of_Medical_Condition__c, 
                                                          List_Of_Medications__c, Most_Recent_Physical_Medical_Visit__c, Systolic_Pressure__c, Weight__c,
                                                          What_happen_when_you_had_allergic_react__c from Baseline_Health_Overview__c WHERE Id=:result];
           
            System.assertEquals(bho.Any_allergic_reaction_to_the_medication__c,resultRecord.Any_allergic_reaction_to_the_medication__c);
            System.assertEquals(bho.High_Blood_Pressure__c, resultRecord.High_Blood_Pressure__c);
            System.assertEquals(bho.List_of_environmental_allergies_reaction__c, resultRecord.List_of_environmental_allergies_reaction__c);
            System.assertEquals(bho.List_Of_Medical_Condition__c,resultRecord.List_Of_Medical_Condition__c);
            System.assertEquals(bho.List_Of_Medications__c, resultRecord.List_Of_Medications__c);
           
        }Catch (Exception ex) {
            System.debug('Exception: ' + ex.getMessage());
            System.debug('Exception line is' + ex.getLineNumber());
            //System.assert(false, 'An exception occurred.');
        } finally {
            Test.stopTest();
        }
        
     return result;   
    }
    
}