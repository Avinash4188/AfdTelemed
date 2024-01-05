@isTest
Private class stripePaymentPortalControllerTest {

    @TestSetup
    static void setData() {
        
         Account a = new Account();
        a.Name ='Test Company';
        insert a;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = a.Id;
        opp.Name = a.Name;
        opp.StageName ='Prospecting';
        opp.CloseDate = System.today();
        opp.Invoice_URL__c = 'https://pay.stripe.com/invoice/acct_1NQhmvL0ztS5fMxY/test_YWNjdF8xTlFobXZMMHp0UzVmTXhZLF9PcjJFR3lob0QxSXRYM3F6dUNiclVCc2dudHBCZEd6LDg4MzU0OTU00200Py6ax6K3/pdf?s=ap';
        Opp.Stripe_Payment_Status__c = 'Paid';
        insert opp;
    }
    @isTest
    static string testfetchOpportunityLink() {
     
        Account a = [SELECT Id,Name FROM Account WHERE Name='Test Company' LIMIT 1];
        Opportunity opp = [SELECT Id,Name,AccountId,stageName,CloseDate,Invoice_URL__c,Stripe_Payment_Status__c FROM Opportunity WHERE AccountId =: a.Id LIMIT 1];
        Test.StartTest();
        string resultLink = stripePaymentPortalController.fetchOpportunityLink(a.Id);
        Test.StopTest();
        System.assertNotEquals(Null,resultLink);
        System.assertEquals('https://pay.stripe.com/invoice/acct_1NQhmvL0ztS5fMxY/test_YWNjdF8xTlFobXZMMHp0UzVmTXhZLF9PcjJFR3lob0QxSXRYM3F6dUNiclVCc2dudHBCZEd6LDg4MzU0OTU00200Py6ax6K3/pdf?s=ap',resultLink);
        return resultLink;
        
    }
    
    @isTest
    static string testfetchOpportunityStatus() {
       
        Account a = [SELECT Id,Name FROM Account WHERE Name='Test Company' LIMIT 1];
        Opportunity opp = [SELECT Id,Name,AccountId,stageName,CloseDate,Invoice_URL__c,Stripe_Payment_Status__c FROM Opportunity WHERE AccountId =: a.Id LIMIT 1];
        
         Test.StartTest();
        string resultStatus = stripePaymentPortalController.fetchOpportunityStatus(a.Id);
        Test.StopTest();
        System.assertNotEquals(Null,resultStatus);
        System.assertEquals('Paid', resultStatus);
        return resultStatus;
    }
}