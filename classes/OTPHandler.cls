public without sharing class OTPHandler {
    @AuraEnabled
    public static Id sendOTP(String firstName, String lastName, String email) {
        List<Lead> existingLead = [SELECT Id, ConvertedAccountId FROM Lead WHERE Email = :email LIMIT 1];
        String OtpCode = '';
        if (!existingLead.isEmpty()){
            System.debug('Inside Main If');
            if (existingLead[0] != null) {
                if (existingLead[0].ConvertedAccountId != null) {
                    throw new AuraHandledException('Patient already exists');
                } else {
                    OtpCode = createAndAssociateOTP(existingLead[0].Id);
                }
            } 
        } 
        else {
            System.debug('Inside Main Else');
            Lead newLead = new Lead();
            newLead.FirstName = firstName;
            newLead.LastName = lastName;
            newLead.Email = email;
            newLead.Company = firstName + ' ' +lastName;
            
            try {
                insert newLead;
                System.debug('New Lead' + newLead);
            } catch(Exception e) {
                throw new AuraHandledException('Error creating lead: ' + e.getMessage());
            }
            System.debug('Before Otp');
            OtpCode = createAndAssociateOTP(newLead.Id);
            System.debug('After Otp' + OtpCode);
            /*
            // Create a new Contact
            List<Contact> recordID = [Select RecordTypeId from contact where RecordType.Name = 'Business' LIMIT 1];
            Contact newContact = new Contact();
            newContact.Lead__c = newLead.Id;
            newContact.FirstName = firstName;
            newContact.LastName = lastName;
            newContact.Email = email;
            newContact.RecordTypeId = recordID[0].RecordTypeId;
            try {
                insert newContact;
                //initiateStudioVerification(newContact.Id);
                System.debug('New Lead' + newContact);
            } catch(Exception e) {
                throw new AuraHandledException('Error creating Contact: ' + e.getMessage());
            }*/
        }
        sendEmail(email, OtpCode);
        List<Lead> existingEmail = [SELECT Id, ConvertedAccountId FROM Lead WHERE Email = :email LIMIT 1];
        return existingEmail.isEmpty() ? null : existingEmail[0].Id;
    }
    
    @AuraEnabled
    public static Boolean verifyOTP(String email, String enteredOTP) {
        
        String storedOTP = getStoredOTP(email);
        return storedOTP != null && storedOTP.equals(enteredOTP);
    }
    
    
    @TestVisible private static String createAndAssociateOTP(Id lead) {
        String otpCode = generateOTP();
        System.debug('Otp' + otpCode);
        TOTP__c otpRecord = new TOTP__c(
            Lead__c = lead,
            OTP__c = otpCode
        );
        insert otpRecord;
        System.debug('otpRecord' + otpRecord);
        return otpCode;
    }
    
    @TestVisible private static String generateOTP() {
        Integer otpLength = 6;
        String validChars = '1234567890';
        String otp = '';
        for (Integer i = 0; i < otpLength; i++) {
            Integer randomIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), validChars.length());
            otp += validChars.substring(randomIndex, randomIndex + 1);
        }
        return otp;
    }
    
    @TestVisible private static void sendEmail(String email, String otp) {
        System.debug('Email:'+ email + 'OTP:' + otp);
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'raghav.sharma@accelirate.com'];
        
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if ( owea.size() > 0 ) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        mail.setToAddresses(new List<String>{email});
        mail.setSubject('Your OTP for Verification');
        mail.setPlainTextBody('Your OTP is: ' + otp);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }
    
    @TestVisible private static String getStoredOTP(String email) {
        DateTime dt = DateTime.now();
        System.debug('email'+email);
        List<TOTP__c> totpRecords = [SELECT OTP__c FROM TOTP__c WHERE Lead__r.email = :email ORDER BY CreatedDate DESC LIMIT 1];
        System.debug('totpRecords'+totpRecords);
        if (!totpRecords.isEmpty()) {
            TOTP__c totpRecord = totpRecords[0];
            String OTP1 = totpRecord.OTP__c;
            return OTP1;
        } else {
            return null;
        }
    }
        
}