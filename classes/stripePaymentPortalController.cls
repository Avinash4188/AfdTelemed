public without sharing class stripePaymentPortalController {
    @AuraEnabled
    public static String fetchOpportunityLink(String accountId) {
        String invoiceUrl;
        String status;
        List<Opportunity> opportunities = [SELECT Invoice_URL__c, Stripe_Payment_Status__c FROM Opportunity WHERE AccountId = :accountId AND StageName != 'Closed Won' LIMIT 1];
        System.debug(opportunities);
        if (!opportunities.isEmpty()) {
            invoiceUrl = opportunities[0].Invoice_URL__c;
            status = opportunities[0].Stripe_Payment_Status__c;
        }
        System.debug(invoiceUrl);
        return invoiceUrl;
    }
    
    @AuraEnabled
    public static String fetchOpportunityStatus(String accountId) {
        String invoiceUrl;
        String status;
        List<Opportunity> opportunities = [SELECT Invoice_URL__c, Stripe_Payment_Status__c FROM Opportunity WHERE AccountId = :accountId AND StageName != 'Closed Won' LIMIT 1];
        if (!opportunities.isEmpty()) {
            invoiceUrl = opportunities[0].Invoice_URL__c;
            status = opportunities[0].Stripe_Payment_Status__c;
        }
        System.debug(status);
        return status;
    }

}