@isTest
private class stripePaymentControllerTest {

    static testmethod String testfetchOpportunityLink() {
        
         //Creating a existingLead
        Lead testLead = new Lead(FirstName='Test',LastName='conversion',Email='avinash4188g@gmail.com');
        Insert testLead;
        
        Opportunity opp = new Opportunity();
        opp.Lead__c = testLead.Id;
        opp.Name = 'TestOpp';
        opp.Invoice_URL__c = 'https://pay.stripe.com/invoice/acct_1NQhmvL0ztS5fMxY/test_YWNjdF8xTlFobXZMMHp0UzVmTXhZLF9PcjJFR3lob0QxSXRYM3F6dUNiclVCc2dudHBCZEd6LDg4MzU0OTU00200Py6ax6K3/pdf?s=ap';
        opp.Stripe_Payment_Status__c = 'Paid';
        opp.StageName = 'Closed Won';
        opp.CloseDate = System.today();
        Insert opp;
        
        Test.StartTest();
        String resultLink = stripePaymentController.fetchOpportunityLink(testLead.Id);
        Test.StopTest();
        System.assertNotEquals(Null,resultLink);
        System.assertEquals('https://pay.stripe.com/invoice/acct_1NQhmvL0ztS5fMxY/test_YWNjdF8xTlFobXZMMHp0UzVmTXhZLF9PcjJFR3lob0QxSXRYM3F6dUNiclVCc2dudHBCZEd6LDg4MzU0OTU00200Py6ax6K3/pdf?s=ap',resultLink);
        
        return resultLink;
    }
    
    static testmethod string testfetchOpportunityStatus() {
        
         //Creating a existingLead
        Lead testLead = new Lead(FirstName='Test',LastName='conversion',Email='avinash4188g@gmail.com');
        Insert testLead;
        
        Opportunity opp = new Opportunity();
        opp.Lead__c = testLead.Id;
        opp.Name = 'TestOpp';
        opp.Invoice_URL__c = 'https://pay.stripe.com/invoice/acct_1NQhmvL0ztS5fMxY/test_YWNjdF8xTlFobXZMMHp0UzVmTXhZLF9PcjJFR3lob0QxSXRYM3F6dUNiclVCc2dudHBCZEd6LDg4MzU0OTU00200Py6ax6K3/pdf?s=ap';
        opp.Stripe_Payment_Status__c = 'Paid';
        opp.StageName = 'Closed Won';
        opp.CloseDate = System.today();
        Insert opp;
        
        Test.StartTest();
        string resultStatus = stripePaymentController.fetchOpportunityStatus(testLead.Id);
        Test.StopTest();
        System.assertNotEquals(Null,resultStatus);
        System.assertEquals('Paid',resultStatus);
        
        return resultStatus;
    }
}