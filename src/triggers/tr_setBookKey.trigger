trigger tr_setBookKey on Book__c (before insert) {
    


    Book__c lastBook = [SELECT S_OriginalKey__c FROM Book__c ORDER BY CreatedDate DESC LIMIT 1];
    
    Integer keyNum = Integer.valueOf(lastBook.S_OriginalKey__c.remove('B'));

    for(Book__c book : Trigger.new){

        if(keyNum >= 1000){
            book.S_OriginalKey__c = 'B' + String.valueOf(keyNum + 1);
        }else{
            book.S_OriginalKey__c = 'B0' + String.valueOf(keyNum + 1);
        }

        keyNum += 1;
    }
    
}