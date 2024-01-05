trigger MentionFeedComment on FeedComment (before insert, before update) {

List<User> listUserPlatform = [SELECT ID, Name FROM User];
List<String> listNameUserPlatform = new List<String>();

for(User u : listUserPlatform) {
    listNameUserPlatform.add('@'+u.Name);
}

for(FeedComment f : Trigger.new) {
    Boolean nameFinded = false;
    for(Integer i=0; i < listNameUserPlatform.size() && !nameFinded; i++) {
        if( f.CommentBody .contains(listNameUserPlatform.get(i)) ) {
            nameFinded=true;
            f.addError('You can\'t use mention');
        }
    }
}
}