@isTest
private class OTPHandlerTest {
	
    static testmethod void testSendOTP_ExistingLead() {
        
        //Creating a existingLead
        Lead existinglead = new Lead(FirstName='Test',LastName='conversion',Email='avinash4188g@gmail.com');
        Insert existinglead;
        
        Test.StartTest();
        Id returnedId =OTPHandler.sendOTP(existinglead.FirstName, existinglead.LastName, existinglead.Email);
        Test.StopTest();
        System.assertNotEquals(null,returnedId);
        System.assertEquals(existinglead.Id,returnedId);
        
    }
    
    static testmethod void testSendOTP_NewLead () {
        
        Test.StartTest();
        Id newLeadId =OTPHandler.sendOTP('Testing', 'lead', 'dastagiri.basha@gmail.com');
        Test.StopTest();
         System.assertNotEquals(null,newLeadId);
        
		Lead testlead = [SELECT Id,Email FROM Lead WHERE Id =:newLeadId]; 
        System.assertNotEquals(null,testlead);
        System.assertEquals('dastagiri.basha@gmail.com',testlead.Email);
        
    }
    
    static testmethod Boolean testverifyOTP() {
        
        // Create a test Lead
        Lead testLead = new Lead();
        testLead.FirstName = 'John';
        testLead.LastName = 'Doe';
        testLead.Email = 'test@example.com';
        testLead.Company = 'Test Company';
        insert testLead;

        // Create a test OTP record
        TOTP__c testOTP = new TOTP__c(
            Lead__c = testLead.Id,
            OTP__c = '123456'
        );
        insert testOTP;

        // Call the verifyOTP method
        Test.StartTest();
        Boolean isValid = OTPHandler.verifyOTP('test@example.com', '123456');
		Test.StopTest();
        // Check if OTP was verified
        System.assertEquals(true, isValid);
    
        return true;
    }
    
    static testmethod String testcreateAndAssociateOTP() {
     
        // Create a test Lead
        Lead testLead1 = new Lead();
        testLead1.FirstName = 'Test';
        testLead1.LastName = 'Example';
        testLead1.Email = 'test@example.com';
        testLead1.Company = 'Test Company';
        insert testLead1;
        
        Test.StartTest();
        String otp = OTPHandler.createAndAssociateOTP(testLead1.Id);
		Test.StopTest();
        
         // Verify that an OTP record was created
        List<TOTP__c> otpRecords = [SELECT Id, OTP__c FROM TOTP__c WHERE Lead__c = :testLead1.Id];
        System.assertEquals(1, otpRecords.size());
        
        // Verify that the generated OTP matches the inserted OTP record
        TOTP__c otpRecord = otpRecords[0];
        System.assertEquals(otp, otpRecord.OTP__c);
        
        // Check if OTP was generated and associated successfully
        System.assertNotEquals(null, otp);
        
        return otp;
    }
    
    static testMethod string testGenerateOTP() {
        // Call the method and assert the result
        String otp = '123456';
         otp = OTPHandler.generateOTP();

        // Check if OTP was generated successfully
        System.assertNotEquals(null, otp);
        System.assertEquals(6, otp.length()); 
        
        return otp;
    }
    
    static testmethod void testSendEmail() {
        // Set up a test lead and OTP
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Email = 'test@example.com'
        );
        insert testLead;
         String otp = '123456';
        Test.StartTest();
         OTPHandler.SendEmail(testLead.Email,otp);
		Test.StopTest();
        
        // Verify that the email was sent
        List<EmailMessage> sentEmails = [SELECT Id FROM EmailMessage WHERE Subject = 'Your OTP for Verification'];
        System.assertEquals(1, sentEmails.size());
    }
    
    
    static testMethod string testGetStoredOTP() {
        
        // Set up a test lead and OTP
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Email = 'test@example.com'
        );
        insert testLead;
        
       // Create an OTP record for the Lead
        String otp = '123456'; // Replace with a valid OTP
        TOTP__c otpRecord = new TOTP__c(
            Lead__c = testLead.Id,
            OTP__c = otp
        );
        insert otpRecord;
        
        // Call the getStoredOTP method
        Test.startTest();
        String storedOTP = OTPHandler.getStoredOTP(testLead.Email);
        Test.stopTest();
        
        // Verify that the retrieved OTP matches the inserted OTP record
        System.assertEquals(otp, storedOTP);
        
        return storedOTP;
    }
    
   
    
}