@isTest
Private class ConvertLeadToPersonAccountAndCreateUserT {

    @TestSetup
    static void setData() {
         // Create a test Lead
        Lead testLead = new Lead();
        testLead.FirstName = 'John';
        testLead.LastName = 'Doe';
        testLead.Email = 'test@example.com';
        testLead.Company = 'Test Company';
        insert testLead;
        
        Account acc = new Account();
        //acc.Id = lcr.getAccountId();
        acc.Name ='Test Account';
        acc.Industry = 'Retail';
        acc.AccountNumber = '123456';
        Insert acc;      
  			
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Initial Patient Visit').getRecordTypeId();
        case c = new case();
        c.AccountId = acc.Id;
        c.Status ='New Patient';
        c.Origin = 'Web';
        c.RecordTypeId = caseRecordTypeId;
        Insert c;       
        
        
    }
    
    static testmethod void testConstructor() {
       /* 
	Lead testLead = [SELECT Id,FirstName,LastName,Email,Company FROM Lead WHERE LastName='Doe' LIMIT 1];       
        ConvertLeadToPersonAccountAndCreateUser cpcu = new ConvertLeadToPersonAccountAndCreateUser(testLead.Id);
        Test.StartTest();
        System.enqueuejob(cpcu);
        Test.StopTest();
      */  
    }
   
  
    static testmethod void testConvertLeadToPersonAccountAndCreateUser() {
        
       // Lead testLead = [SELECT Id,FirstName,LastName,Email,Company,isConverted FROM Lead WHERE LastName='Doe' LIMIT 1];   

        // Create a test Lead
        Lead testLead3 = new Lead();
        testLead3.FirstName = 'lead';
        testLead3.LastName = 'Doe5';
        testLead3.Email = 'test@example.com';
        testLead3.Company = 'Test Company';
        testLead3.Status = 'Qualified';
        insert testLead3;
        
         //ConvertLeadToPersonAccountAndCreateUser cpcuList = new ConvertLeadToPersonAccountAndCreateUser(Null);
         //System.enqueueJob(cpcuList);
         ConvertLeadToPersonAccountAndCreateUser cpuClass = new ConvertLeadToPersonAccountAndCreateUser(testLead3.Id);
        cpuClass.execute(Null);
        
         // Create a test Lead
        Lead testLead6 = new Lead();
        testLead6.FirstName = 'lead';
        testLead6.LastName = 'Doe6';
        testLead6.Email = 'test@example.com';
        testLead6.Company = 'Test Company';
        testLead6.Status = 'Qualified';
        insert testLead6;
        
            // Convert the Lead to a Person Account
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(testLead6.Id);
                lc.setDoNotCreateOpportunity(true); 
                lc.setAccountId(null); 
                lc.setConvertedStatus('Qualified'); 
                Database.LeadConvertResult lcr = Database.convertLead(lc);
            
 				 Id convertedAccountId = lcr.getAccountId();
            
               Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
                /*
                Account acc = new Account();
                //acc.Id = lcr.getAccountId();
                acc.Name ='Test Account';
                acc.Industry = 'Retail';
                acc.AccountNumber = '123456';
                Insert acc;
                */
        
        Account convertedAccount = [SELECT Id FROM Account WHERE Id = : convertedAccountId  LIMIT 1];
                                         
       		/* Account convertedAccount = [SELECT Id FROM Account WHERE Id = :lcr.getAccountId()];
                Account accountToUpdate = new Account();
                accountToUpdate.Id = convertedAccount.Id;
                accountToUpdate.RecordTypeId = accountRecordTypeId;
                update accountToUpdate;
               */ 
               String username = testLead3.Email;
              
                 string uname = Userinfo.getUserName();
                
                Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Patient' LIMIT 1];
               /*
                       User u = new User();
                        u.FirstName = testLead3.FirstName;
                        u.LastName = testLead3.LastName;
                        u.ContactId = lcr.getContactId();
                        u.Username = username;
                        u.Email = testLead3.Email;
                        u.CommunityNickname = username;
                        u.Alias = username.substring(0,8);
                        u.TimeZoneSidKey = 'GMT';
                        u.LocaleSidKey = 'en_US';
                        u.EmailEncodingKey = 'UTF-8';
                        u.ProfileId = profileId.Id;
                        u.LanguageLocaleKey = 'en_US';
                        u.IsActive = true;
                        Insert u;    
                */                  
                
               //testleadData();
        
        Test.StartTest();
        ConvertLeadToPersonAccountAndCreateUser cpcu = new ConvertLeadToPersonAccountAndCreateUser(testLead3.Id);
        System.enqueueJob(cpcu);
        Test.StopTest();
        
    }
   
    static testmethod void testleadData() {
        
        Lead testLead = [SELECT Id,FirstName,LastName,Email,Company FROM Lead WHERE LastName='Doe' LIMIT 1];  
        Account accountid = [SELECT Id,Name FROM Account WHERE name ='Test Account' LIMIT 1];
        case cases = [SELECT Id,AccountId,Status,Origin,RecordTypeId FROM Case LIMIT 1];
        try {
            case c = new case();
            c.AccountId = accountid.Id;
            c.Status ='New Patient';
            c.Origin = 'Web';
            c.RecordTypeId = cases.RecordTypeId;
            Insert c;
            
        }catch(Exception e) {
            System.debug('Exception is :' + e.getMessage());
        }
		
		//case caseID = [Select id from case where AccountId = :accountId LIMIT 1];
        testupdateBaselineHealthOverview();
        testupdatePharmacy();
        testupdateBaselineResponse();
        testupdateStripe();
        testupdateConsent();
        //testmoveFilesToAccount();
        testupdateMedicalCondition();
        testupdateOpportunity();
        
        
        
        //Test.StartTest();
        ConvertLeadToPersonAccountAndCreateUser.leadData(testLead.Id, accountId.Id);
        //Test.StopTest();
        case caserecord = [SELECT Id,AccountId,Status,Origin,RecordTypeId FROM Case LIMIT 1];
        System.assertEquals('New Patient', caserecord.Status);
        //System.assertEquals('Initial Patient Visit',caserecord.RecordTypeId);
        
    }
	
    
    static testmethod void testupdateBaselineHealthOverview() {
        
        Lead testLead = [SELECT Id,FirstName,LastName,Email,Company FROM Lead WHERE LastName='Doe' LIMIT 1];  
        Account accountid = [SELECT Id,Name FROM Account WHERE name ='Test Account' LIMIT 1];
        List<Baseline_Health_Overview__c> bhoList = new List<Baseline_Health_Overview__c>();
        Baseline_Health_Overview__c bho = new Baseline_Health_Overview__c();
        bho.Lead__c = testLead.Id;
        bhoList.add(bho);
        
        Baseline_Health_Overview__c bho1 = new Baseline_Health_Overview__c();
        bho1.Lead__c = testLead.Id;
        bhoList.add(bho1);
        Insert bhoList;
        
        for(Baseline_Health_Overview__c record : bhoList) {
            
            record.Account__c = accountid.Id;
        }
        
        if(!bhoList.isEmpty()) {
            Update bhoList;
        }
        
        Test.StartTesT();
        ConvertLeadToPersonAccountAndCreateUser.updateBaselineHealthOverview(testLead.Id, accountid.Id);
        Test.StopTest();
        
        Baseline_Health_Overview__c bhoUpdate = [SELECT Id,Lead__c,Account__c FROM Baseline_Health_Overview__c LIMIT 1];
        System.assertEquals(bhoList[0].Account__c, bhoUpdate.Account__c);
    }
    
    static testmethod void testupdatePharmacy() {
        
        Lead testLead = [SELECT Id,FirstName,LastName,Email,Company FROM Lead WHERE LastName='Doe' LIMIT 1];  
        Account accountid = [SELECT Id,Name FROM Account WHERE name ='Test Account' LIMIT 1];
        
        List<Pharmacy_Location__c> phlist = new List<Pharmacy_Location__c>();
        Pharmacy_Location__c pl = new Pharmacy_Location__c();
        pl.Lead__c = testLead.Id;
        phlist.add(pl);
        Pharmacy_Location__c pl1 = new Pharmacy_Location__c();
        pl1.Lead__c = testLead.Id;
		phlist.add(pl1);
        Insert phlist;
        
        for(Pharmacy_Location__c record : phlist) {
            record.Account__c = accountid.Id;
        }
        
        if(!phlist.isEmpty()) {
            Update phlist;
        }
        
        //Test.StartTest();
        ConvertLeadToPersonAccountAndCreateUser.updatePharmacy(testLead.Id, accountId.Id);
        //Test.StopTest();
        Pharmacy_Location__c plUpdate = [SELECT Id,Lead__c,Account__c FROM Pharmacy_Location__c LIMIT 1];
        System.assertEquals(phlist[0].Account__c,plUpdate.Account__c);
        
    }
    
    static testmethod void testupdateBaselineResponse() {
        
        Lead testLead = [SELECT Id,FirstName,LastName,Email,Company FROM Lead WHERE LastName='Doe' LIMIT 1];  
        Account accountid = [SELECT Id,Name FROM Account WHERE name ='Test Account' LIMIT 1];
        case caseid = [SELECT Id FROM Case WHERE AccountId=:accountid.Id LIMIT 1];
        
        List<Baseline_Response__c> brList = new List<Baseline_Response__c>();
        Baseline_Response__c br = new Baseline_Response__c();
        br.Lead__c = testLead.Id;
        brList.add(br);
        Baseline_Response__c br1 = new Baseline_Response__c();
        br1.Lead__c = testLead.Id;
        brList.add(br1);
        Insert brList;
        for(Baseline_Response__c record : brList) {
            record.Account__c = accountid.Id;
            record.case__c = caseid.Id;
        }
        
        if(!brList.isEmpty()) {
            Update brList;
        }
        
        //Test.StartTest();
        ConvertLeadToPersonAccountAndCreateUser.updateBaselineResponse(testLead.Id, accountId.Id, caseid.Id);
        //Test.StopTest();
        Baseline_Response__c updatebrList = [SELECT Id,Account__c,Lead__c,Case__c FROM Baseline_Response__c LIMIT 1];
        System.assertEquals(brList[0].Account__c,updatebrList.Account__c);
        System.assertEquals(brList[0].Case__c,updatebrList.Case__c);
    }
    
    static testmethod void testupdateStripe() {
        
        Lead testLead = [SELECT Id,FirstName,LastName,Email,Company FROM Lead WHERE LastName='Doe' LIMIT 1];  
        Account accountid = [SELECT Id,Name FROM Account WHERE name ='Test Account' LIMIT 1];
        List<Stripe_Payments_Logs__c> splList = new List<Stripe_Payments_Logs__c>();
        Stripe_Payments_Logs__c spl = new Stripe_Payments_Logs__c();
        spl.Lead__c = testLead.Id;
        splList.add(spl);
        Stripe_Payments_Logs__c spl1 = new Stripe_Payments_Logs__c();
        spl1.Lead__c = testLead.Id;
        splList.add(spl1);
        Insert splList;
         for (Stripe_Payments_Logs__c record : splList) {
            record.Account__c = accountId.Id;
        }

        if (!splList.isEmpty()) {
            update splList;
        }
        
       //Test.StartTest();
        ConvertLeadToPersonAccountAndCreateUser.updateStripe(testLead.Id, accountId.Id);
        //Test.StopTest();
        Stripe_Payments_Logs__c splUpdate = [SELECT Id,Lead__c,Account__c FROM Stripe_Payments_Logs__c LIMIT 1];
        System.assertEquals(splList[0].Account__c,splUpdate.Account__c);
    }

    static testmethod void testupdateConsent() {
        
        Lead testLead = [SELECT Id,FirstName,LastName,Email,Company FROM Lead WHERE LastName='Doe' LIMIT 1];  
        Account accountid = [SELECT Id,Name FROM Account WHERE name ='Test Account' LIMIT 1];
        
        List<Consent_Logs__c> conLogs = new List<Consent_Logs__c>();
        Consent_Logs__c cl = new Consent_Logs__c();
        cl.Lead__c = testLead.Id;
        conLogs.add(cl);
        Consent_Logs__c cl1 = new Consent_Logs__c();
        cl1.Lead__c = testLead.Id;
        conLogs.add(cl1);
        Insert conLogs;
        
        for(Consent_Logs__c record : conLogs) {
            record.Account__c = accountid.Id;
        }
        
        if(!conLogs.isEmpty()) {
            Update conLogs;
        }
        
        //Test.StartTest();
        ConvertLeadToPersonAccountAndCreateUser.updateConsent(testLead.Id, accountId.Id);
        //Test.StopTest();
        Consent_Logs__c updateList = [SELECT Id,Lead__c,Account__c FROM Consent_Logs__c LIMIT 1];
        System.assertEquals(conLogs[0].Account__c,updateList.Account__c);
        System.assertEquals(conLogs[1].Account__c,updateList.Account__c);
    }
    
    static testmethod void testmoveFilesToAccount() {
        
         Lead testLead = [SELECT Id,FirstName,LastName,Email,Company FROM Lead WHERE LastName='Doe' LIMIT 1];  
        Account accountid = [SELECT Id,Name FROM Account WHERE name ='Test Account' LIMIT 1];
        case caseid = [SELECT Id FROM Case WHERE AccountId=:accountid.Id LIMIT 1];
        /*
         Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Patient' LIMIT 1];
         User testUser = [SELECT Id,ProfileId FROM User WHERE Username = 'accelirate@telemed.com.partial' LIMIT 1];
        
        System.runAs(testUser) {            
        ContentVersion testContent = new ContentVersion();
        testContent.Title = 'TestContent';
        testContent.VersionData = Blob.ValueOf('Test Content Data');
        testContent.PathOnClient = 'test.txt';
        insert testContent;
        
        ContentDocumentLink testLink = new ContentDocumentLink();
        testLink.LinkedEntityId = testLead.Id;
        testLink.ContentDocumentId = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id=: testContent.Id].Id;
        Insert testLink;
    }
        */
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
         ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'Test Document1';
        cv1.PathOnClient = 'TestDocument1.pdf';
        cv1.VersionData = Blob.valueOf('Test Content1');
        cv1.IsMajorVersion = true;
        Insert cv1;
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        Id conDocId1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv1.Id].ContentDocumentId;
        
        string uname = Userinfo.getUserName();
        
         //Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Patient' LIMIT 1];
         User testUser = [SELECT Id,ProfileId FROM User WHERE Username =:uname LIMIT 1];
       List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        System.runAs(testUser) {
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = testLead.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.ShareType = 'v';
        cdlList.add(cdl);
        
        ContentDocumentLink cdl1 = new ContentDocumentLink();
        cdl1.LinkedEntityId = testLead.Id;
        cdl1.ContentDocumentId = conDocId1;
        cdl1.ShareType = 'v';
        cdlList.add(cdl1);
     }
        Insert cdlList;
        
        delete cdlList;
     
        List<ContentDocumentLink> newCdlList = new List<ContentDocumentLink>();
        for(ContentDocumentLink file: cdlList) {
          ContentDocumentLink newCdl = new ContentDocumentLink();
            newCdl.LinkedEntityId = accountid.Id;
            newCdl.ContentDocumentId = file.ContentDocumentId;
            newCdl.ShareType = 'v';
            newCdlList.add(newCdl);      
        }
        
        for(ContentDocumentLink recordCase : cdlList) {
            ContentDocumentLink newCdl = new ContentDocumentLink();
            newCdl.LinkedEntityId = caseid.Id;
            newCdl.ContentDocumentId = recordCase.ContentDocumentId;
            newCdl.ShareType = 'v';
            newCdlList.add(newCdl);
        }
        
        if(!newCdlList.isEmpty()) {
             Insert newCdlList;
        }
        
        
        Test.StartTest();
        ConvertLeadToPersonAccountAndCreateUser.moveFilesToAccount(testLead.Id, accountId.Id, caseId.Id);
        Test.StopTest();
        ContentDocumentLink updatecdlink = [SELECT LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: accountid.Id LIMIT 1];
        System.assertEquals(newCdlList[0].LinkedEntityId,updatecdlink.LinkedEntityId);
        System.assertEquals(newCdlList[1].LinkedEntityId,updatecdlink.LinkedEntityId);
        System.assertEquals(accountid.Id, updatecdlink.LinkedEntityId);
    }
    
    static testmethod void testupdateMedicalCondition() {
        
        Lead testLead = [SELECT Id,FirstName,LastName,Email,Company FROM Lead WHERE LastName='Doe' LIMIT 1];  
        Account accountid = [SELECT Id,Name FROM Account WHERE name ='Test Account' LIMIT 1];
        List<Medical_Condition__c> mcList = new List<Medical_Condition__c>();
        Medical_Condition__c mc = new Medical_Condition__c();
        mc.Lead__c = testLead.Id;
        mcList.add(mc);
        Medical_Condition__c mc1 = new Medical_Condition__c();
        mc1.Lead__c = testLead.Id;
        mcList.add(mc1);
        Insert mcList;
        
        for(Medical_Condition__c record : mcList) {
            record.Account__c = accountid.Id;
        }
        
        if(!mcList.isEmpty()) {
            update mcList;
        }
        
        //Test.StartTest();
        ConvertLeadToPersonAccountAndCreateUser.updateMedicalCondition(testLead.Id, accountId.Id);
        //Test.StopTest();
        Medical_Condition__c updatemc = [SELECT Id,Lead__c,Account__c FROM Medical_Condition__c LIMIT 1];
        System.assertEquals(mcList[0].Account__c, updatemc.Account__c);
        System.assertEquals(mcList[1].Account__c, updatemc.Account__c);
    }
    
    static testmethod void testupdateOpportunity() {
        
         Lead testLead = [SELECT Id,FirstName,LastName,Name,Email,Company FROM Lead WHERE LastName='Doe' LIMIT 1];  
        Account accountid = [SELECT Id,Name FROM Account WHERE name ='Test Account' LIMIT 1];
        
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.Lead__c = testLead.Id;
        opp.Name = testLead.Name;
        opp.StageName = 'Qualification';
        opp.CloseDate = System.today();
        oppList.add(opp);
        Opportunity opp1 = new Opportunity();
        opp1.Lead__c = testLead.Id;
        opp1.Name = testLead.Name;
        opp1.StageName = 'Qualification';
        opp1.CloseDate = System.today();
        oppList.add(opp1);
        Insert oppList;
        
        for(Opportunity recordOpp: oppList) {
            recordOpp.AccountId = accountid.Id;
        }
        
        if(!oppList.isEmpty()) {
            Update oppList;
        }
        
        //Test.StartTesT();
        ConvertLeadToPersonAccountAndCreateUser.updateOpportunity(testLead.Id, accountId.Id);
        //Test.StopTest();
        Opportunity oppUpdate = [SELECT Id,Lead__c,AccountId FROM Opportunity LIMIT 1];
        System.assertEquals(oppList[0].AccountId, oppUpdate.AccountId);
        System.assertEquals(oppList[1].AccountId, oppUpdate.AccountId);
    }
}