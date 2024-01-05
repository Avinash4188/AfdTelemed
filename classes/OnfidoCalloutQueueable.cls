public without sharing class OnfidoCalloutQueueable  implements Queueable, Database.AllowsCallouts {
    public  Id contactId;
    public OnfidoCalloutQueueable(Id contactId ) {
        this.contactId = contactId;
    }
    
    public void execute(QueueableContext context) {
        List<onfidosf.onfido_verificationsInvocableStudio.initiateStudioVerificationRequest> objList = new List<onfidosf.onfido_verificationsInvocableStudio.initiateStudioVerificationRequest>();
        onfidosf.onfido_verificationsInvocableStudio.initiateStudioVerificationRequest obj = new onfidosf.onfido_verificationsInvocableStudio.initiateStudioVerificationRequest();
        obj.recordId = contactId;
        obj.language = 'en_US';
        obj.sendEmail = false;
        obj.workflowId = '9e300e1c-d26c-4fe6-984c-50a1c6813da1';
        objList.add(obj);
        List<String> result = onfidosf.onfido_verificationsInvocableStudio.initiateStudioVerification(objList);
        System.debug('result:'+result);
        
    }
    
}