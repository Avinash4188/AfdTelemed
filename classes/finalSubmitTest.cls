@isTest
private class finalSubmitTest {
    
    static testmethod void testfinalSubmittion() {
        
	 // Create a test Lead
        Lead testLead = new Lead();
        //testLead.FirstName = 'John';
        testLead.LastName = 'John Doe';
        testLead.Email = 'test@example.com';
        testLead.Company = 'Test Company';
        insert testLead;
    
    Test.StartTest();
    finalSubmit.finalSubmittion(testLead.Id);
    Test.StopTest();
    }
}