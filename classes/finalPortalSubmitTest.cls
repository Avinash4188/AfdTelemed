@isTest
Private class finalPortalSubmitTest {
    
    @TestSetup() 
    static void setData() {
        
        Account a = new Account();
        a.Name = 'TestAccount';
        //a.PersonEmail = 'testshaik@gmail.com';
        Insert a;
        
        
        Opportunity opp = new Opportunity();
        opp.AccountId = a.Id;
        opp.Name = a.Name;
        opp.StageName ='Qualification';
        opp.CloseDate = System.today();
        insert opp;
        
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Initial Patient Visit').getRecordTypeId(); 
        Case newCase = New Case();
        newCase.AccountId = a.Id;
        newCase.Status = 'New Patient';
        newCase.Origin = 'Web';
        newCase.SuppliedEmail = a.PersonEmail;
        newCase.RecordTypeId = caseRecordTypeId;
        insert newCase;
        
    }
    
    @isTest
    public static void testleadData() {
        
        Account accRecord = [SELECT Id,Name,PersonEmail FROM Account WHERE Name='TestAccount' LIMIT 1];
        Opportunity opp = [SELECT Id,Name,stageName,closeDate FROM Opportunity WHERE AccountId =: accRecord.Id LIMIT 1];
        Case caseRecord = [SELECT Id,AccountId,Status,Origin,SuppliedEmail,RecordTypeId FROM Case WHERE AccountId =: accRecord.Id LIMIT 1];
        
        Test.StartTest();
        finalPortalSubmit.leadData(accRecord.Id);
        Test.StopTest();
        Integer caseCount = [SELECT COUNT() FROM Case];
        System.assertEquals(2, caseCount);
        
        Integer opportunityCount = [SELECT COUNT() FROM Opportunity];
        System.assertEquals(1, opportunityCount);
        
        testupdateBaselineResponse();
        testupdateStripe();
        testmoveFilesToAccount();
    }
   
    @isTest
    static void testupdateBaselineResponse() {
        
        Account accRecord = [SELECT Id,Name,PersonEmail FROM Account WHERE Name='TestAccount' LIMIT 1];
        Opportunity oppRecord = [SELECT Id,AccountId,Name,StageName,CloseDate FROM Opportunity WHERE AccountId =: accRecord.Id LIMIT 1];
        Case caseRecord = [SELECT Id,AccountId,Status,Origin,SuppliedEmail,RecordTypeId FROM Case WHERE AccountId =: accRecord.Id LIMIT 1];
        
        Baseline_Response__c br = new Baseline_Response__c();
        br.Opportunity__c = oppRecord.Id;
        Insert br;
        
        Baseline_Response__c newBR = new Baseline_Response__c(Id= br.Id);
        newBR.Account__c = accRecord.Id;
        newBR.Case__c = caseRecord.Id;
        Update newBR;
        
        //Test.StartTest();
        finalPortalSubmit.updateBaselineResponse(oppRecord.Id, accRecord.Id, caseRecord.Id);
        //Test.StopTest();
        Baseline_Response__c updateBR = [SELECT Account__c,Case__c FROM Baseline_Response__c];
        System.assertEquals(accRecord.Id, updateBR.Account__c);
        System.assertEquals(CaseRecord.Id, updateBR.Case__c);
        
    }
    
    @isTest
    static void testupdateStripe() {
        
        Account accRecord = [SELECT Id,Name,PersonEmail FROM Account WHERE Name='TestAccount' LIMIT 1];
        Opportunity oppRecord = [SELECT Id,AccountId,Name,StageName,CloseDate FROM Opportunity WHERE AccountId =: accRecord.Id LIMIT 1];
        
        Stripe_Payments_Logs__c spl = new Stripe_Payments_Logs__c();
        spl.Opportunity__c = oppRecord.Id;
        Insert spl;
        
        Stripe_Payments_Logs__c splNew = new Stripe_Payments_Logs__c(Id=spl.Id);
        splNew.Account__c = accRecord.Id;
        Update splNew;
        
        //Test.StartTest();
        finalPortalSubmit.updateStripe(oppRecord.Id, accRecord.Id);
        //Test.StopTest();
        Stripe_Payments_Logs__c updateSPLRecord = [SELECT Id,Opportunity__c,Account__c FROM Stripe_Payments_Logs__c];
        System.assertEquals(spl.Opportunity__c,updateSPLRecord.Opportunity__c);
        System.assertEquals(splNew.Account__c,updateSPLRecord.Account__c);
    }
    
    @isTest
    static void testmoveFilesToAccount() {
        
        Account accRecord = [SELECT Id,Name,PersonEmail FROM Account WHERE Name='TestAccount' LIMIT 1];
        Opportunity oppRecord = [SELECT Id,AccountId,Name,StageName,CloseDate FROM Opportunity WHERE AccountId =: accRecord.Id LIMIT 1];
        Case caseRecord = [SELECT Id,AccountId,Status,Origin,SuppliedEmail,RecordTypeId FROM Case WHERE AccountId =: accRecord.Id LIMIT 1];
        
        List<ContentVersion> newVersionsForAccount = new List<ContentVersion>();
        List<ContentVersion> newVersionsForCase = new List<ContentVersion>();
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        cv.SharingPrivacy = 'N';
        Insert cv;
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = oppRecord.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.ShareType = 'v';
        Insert cdl;
        
        
        ContentVersion newVersionForAccount = new ContentVersion(
            Title = cv.Title,
            PathOnClient = cv.PathOnClient,
            VersionData = cv.VersionData,
            SharingPrivacy = cv.SharingPrivacy,
            FirstPublishLocationId = accRecord.Id
        );
        newVersionsForAccount.add(newVersionForAccount);
        
        // Create a new ContentVersion for the Case
        ContentVersion newVersionForCase = new ContentVersion(
            Title = cv.Title,
            PathOnClient = cv.PathOnClient,
            VersionData = cv.VersionData,
            SharingPrivacy = cv.SharingPrivacy,
            FirstPublishLocationId = caseRecord.Id
        );
        newVersionsForCase.add(newVersionForCase);
        
         if (!newVersionsForAccount.isEmpty()) {
            insert newVersionsForAccount;
        }
        
        if (!newVersionsForCase.isEmpty()) {
            insert newVersionsForCase;
        }
    
    //Test.StartTest();
    finalPortalSubmit.moveFilesToAccount(oppRecord.Id, accRecord.Id, caseRecord.Id);
   //Test.StopTest();
    //ContentVersion cvList = [SELECT FirstPublishLocationId FROM ContentVersion]; 
    System.assertEquals(newVersionsForAccount[0].FirstPublishLocationId,accRecord.Id);    
    System.assertEquals(newVersionsForCase[0].FirstPublishLocationId,caseRecord.Id);
}
    
}