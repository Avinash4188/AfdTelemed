trigger CreateAuthorNote on ContentVersion (after insert) {
   /* List<AuthorNote> authorNotesToInsert = new List<AuthorNote>();
    
    for (ContentVersion cv : Trigger.new) {
        if (cv.FileType == 'SNOTE' && .LinkedEntityId.getSObjectType() == Case.sObjectType) {
            List<ContentVersion> conVer = [SELECT Id, ContentDocumentId, FileType, TextPreview, Title, VersionData FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
            
            if (!conVer.isEmpty()) {
                
                System.debug(conVer);
                
                List<ContentDocumentLink> conDocuLinks = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId = :conVer[0].ContentDocumentId];
                System.debug(conDocuLinks);
                
                for (ContentDocumentLink conDocuLink : conDocuLinks) {
                    if (conDocuLink != null && conDocuLink.LinkedEntityId.getSObjectType() == Case.sObjectType) {
                        
                        System.debug(conDocuLink.LinkedEntityId);
                        
                        AuthorNote autNote = new AuthorNote();
                        autNote.NoteText = 'General Notes';
                        autNote.Body__c = conVer[0].TextPreview;
                        autNote.ParentRecordId = conDocuLink.LinkedEntityId;
                        autNote.Case__c = conDocuLink.LinkedEntityId;
                        
                        authorNotesToInsert.add(autNote);
                    }
                }
            }
        }
    }
    
    if (!authorNotesToInsert.isEmpty()) {
        insert authorNotesToInsert;
    }
    System.debug(authorNotesToInsert);*/
}