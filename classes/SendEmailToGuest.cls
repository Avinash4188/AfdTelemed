public class SendEmailToGuest {
    
    @InvocableMethod(label='Send Email To Guest' callout='true')
    public static Void SendEmailToGuestUsingEmailTemplate(List<inputvariables> inputParams)
    {
        EmailTemplate et = [SELECT Id,Subject, Body FROM EmailTemplate WHERE DeveloperName ='SchedulerUnauthenticatedUserAppointmentTypeEmailTemplateForThirdParty'];
        List<string> toAddress = new List<string>();
        toAddress.add(inputParams.get(0).leadEmail);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(et.Id);
        mail.setToAddresses(toAddress);
        mail.setTargetObjectId(inputParams.get(0).leadId);
        mail.setWhatId(inputParams.get(0).appointmentId);
        mail.setSaveAsActivity(false);
        mail.setUseSignature(false);
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        allmsg.add(mail);
        try {
            Messaging.sendEmail(allmsg,false);
            return;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
    
    public class inputvariables {
        @InvocableVariable
        public String leadEmail;
        @InvocableVariable
        public String leadId;
        @InvocableVariable
        public String appointmentId;
    } 
}