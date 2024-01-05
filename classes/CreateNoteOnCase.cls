public class CreateNoteOnCase {
    
    @InvocableMethod
    public static void callflow(List<Id> caseIds) {
        // Query Baseline_Response__c records related to the Case
        List<Baseline_Response__c> responses = [
            SELECT Id, Response__c, Question__c, Sort_Order__c, Case__c
            FROM Baseline_Response__c 
            WHERE Case__c = :caseIds 
            ORDER BY Sort_Order__c
        ];
        
        // Create a string to hold the concatenated note body
        String noteBody = '';
        
        // Iterate through responses to build the note body
        for (Baseline_Response__c response : responses) {
            noteBody += response.Sort_Order__c +'   Question: ' + response.Question__c + '<br/>   Response: ' + response.Response__c + '<br/><br/>';
        }
        
        String noteBodyCom = '<b>Initial SOAP:</b> '+ '<br/><br/>'+ noteBody +'<b>Objective:</b>'+ '<br/><br/>'+'<b>Assessment:</b>'+ '<br/><br/>'+'<b>Plan:</b><br/>';
        
        // Create a single ContentNote
        ContentNote contentNote = new ContentNote();
        contentNote.Title = 'General Notes';
        contentNote.Content = Blob.valueOf(noteBodyCom);
        
        // Insert the ContentNote
        insert contentNote;
        
        // Create a new ContentDocumentLink
        ContentDocumentLink link = new ContentDocumentLink();
        link.ContentDocumentId = contentNote.Id;
        link.LinkedEntityId = caseIds[0];
        link.ShareType = 'V';
        link.Visibility = 'AllUsers';
        
        
        // Insert the ContentDocumentLink
        insert link;
        
        
    }
}