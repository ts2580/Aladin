Cache.OrgPartition orgPart = Cache.Org.getPartition('local.book');

Map<String, Book__c> mapBook = (Map<String, Book__c>)orgPart.get('books');

Integer i = 0;
for (String key : mapBook.keyset()) {
    System.debug('i >>' + i);
    System.debug(mapBook.get(key));
    i++;
}