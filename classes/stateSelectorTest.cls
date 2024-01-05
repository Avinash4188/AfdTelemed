@isTest
class stateSelectorTest {

    @TestSetup
    static void setup() {
        
      //Create a test Lead
        Lead testLead = new Lead();
        testLead.FirstName = 'John';
        testLead.LastName = 'Doe';
        testLead.Email = 'test@example.com';
        testLead.Company = 'Test Company';
        testLead.State__c = 'Alabama';
        insert testLead;   
    }
    static testmethod List<string> teststateSelector() {
        
         Lead testLead =[SELECT Id,FirstName,LastName,Email,Company,State__c FROM Lead WHERE LastName=:'Doe' LIMIT 1];
        
        Test.StartTest();
        List<String> statepicklistValues = stateSelector.stateSelector();
        Test.StopTest();
        System.assertNotEquals(Null,statepicklistValues);
        System.assertEquals(50, statepicklistValues.size());
        System.assertEquals('Alabama', statepicklistValues[0]);
        
        return statepicklistValues;   
    }
    
    static testmethod void testupdateState() {
        
        Lead testLead =[SELECT Id,FirstName,LastName,Email,Company,State__c FROM Lead WHERE LastName=:'Doe' LIMIT 1];
                    
        Lead updateLead = new Lead();
        updateLead.Id =testLead.Id;
        updateLead.State__c = 'Alaska';
        Update updateLead;
        
        Test.StartTest();
        stateSelector.updateState(updateLead.Id, 'Alaska');
        Test.StopTest();
        
        Lead updateresult = [SELECT Id,FirstName,LastName,Email,Company,State__c FROM Lead WHERE id =:updateLead.Id];
        System.assertNotEquals(Null,updateresult);
        System.assertEquals(updateresult.State__c,updateLead.State__c);
    }
}