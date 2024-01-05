public without sharing class stripePaymentController {
    @AuraEnabled
    public static String fetchOpportunityLink(String leadId) {
        String invoiceUrl;
        String status;
        List<Opportunity> opportunities = [SELECT Invoice_URL__c, Stripe_Payment_Status__c FROM Opportunity WHERE Lead__c = :leadId LIMIT 1];
        if (!opportunities.isEmpty()) {
            invoiceUrl = opportunities[0].Invoice_URL__c;
            status = opportunities[0].Stripe_Payment_Status__c;
        }
        return invoiceUrl;
    }
    
    @AuraEnabled
    public static String fetchOpportunityStatus(String leadId) {
        String invoiceUrl;
        String status;
        List<Opportunity> opportunities = [SELECT Invoice_URL__c, Stripe_Payment_Status__c FROM Opportunity WHERE Lead__c = :leadId LIMIT 1];
        if (!opportunities.isEmpty()) {
            invoiceUrl = opportunities[0].Invoice_URL__c;
            status = opportunities[0].Stripe_Payment_Status__c;
        }
        return status;
    }
}