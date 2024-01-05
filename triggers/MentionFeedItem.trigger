trigger MentionFeedItem on FeedItem (before insert, before update) {

List<User> listUserPlatform = [SELECT ID, Name FROM User];
List<String> listNameUserPlatform = new List<String>();

for(User u : listUserPlatform) {
    listNameUserPlatform.add('@'+u.Name);
    //listNameUserPlatform.add('@'+u.CommunityNickname);
}

for(FeedItem f : Trigger.new) {
    Boolean nameFinded = false;
    for(Integer i=0; i < listNameUserPlatform.size() && !nameFinded; i++) {
        if( f.Body.contains(listNameUserPlatform.get(i)) ) {
            nameFinded=true;
            f.addError('You can\'t use mention');
        }
    }
}
}