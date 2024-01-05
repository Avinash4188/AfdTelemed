trigger CreateAuthorNoteFromContentNote on ContentDocumentLink (after insert,after update) {
    List<AuthorNote> authorNotesToInsert = new List<AuthorNote>();
    Map<Id,Id> cdlMap =  new  Map<Id,Id>();
    for (ContentDocumentLink cdl : Trigger.new) {
        if (cdl.ContentDocument.FileType == 'SNOTE' && cdl.LinkedEntityId.getSObjectType() == Case.sObjectType) {
            cdlMap.put(cdl.ContentDocument.LatestPublishedVersionId,cdl.LinkedEntityId);
        }
    }
    List<ContentVersion> cvList = [SELECT Id, ContentDocumentId, FileType, TextPreview, Title, VersionData FROM ContentVersion WHERE Id = :cdlMap.keySet()];
    System.debug(cvList);
    for (ContentVersion conVer : cvList) {
        
        AuthorNote autNote = new AuthorNote();
        autNote.NoteText = conVer.Title;
        autNote.Body__c = conVer.TextPreview;
        autNote.ParentRecordId = cdlMap.get(conVer.Id);
        autNote.Case__c =  cdlMap.get(conVer.Id);
        
        authorNotesToInsert.add(autNote);
    }
    if (!authorNotesToInsert.isEmpty()) {
        System.debug(authorNotesToInsert);
        insert authorNotesToInsert;
    }
    System.debug(authorNotesToInsert);
}