/**
 * Created by 한성진 on 2023-03-22.
 */

public with sharing class tr_Book extends TriggerHandler{
    private Map<Id, Book__c> mapOld{get; set;}
    private List<Book__c> listNew{get; set;}
    private List<Book__c> listOld{get; set;}

    public tr_Book() {
        mapOld = (Map<Id, Book__c>) Trigger.oldMap;
        listNew = (List<Book__c>) Trigger.new;
        listOld = (List<Book__c>) Trigger.old;
    }

    public override void beforeInsert() {
        setKey(listNew);
    }

    /************************************************************************************
    *  Before Insert Method
    *************************************************************************************/
    //-----------------------------------------------------------------------------------------------------------
    //  내용 : 책의 Key(그룹 코드 값 + 코드 값)와 이름(코드 값)을 만들어주는 트리거.
    //-----------------------------------------------------------------------------------------------------------
    public static void setKey(List<Book__c> listNew){

        Book__c lastBook = [
                SELECT S_OriginalKey__c
                FROM Book__c
                ORDER BY CreatedDate DESC LIMIT 1
        ];

        Integer keyNum = Integer.valueOf(lastBook.S_OriginalKey__c.remove('B'));

        for(Book__c book : listNew){

            if(keyNum >= 1000){
                book.S_OriginalKey__c = 'B' + String.valueOf(keyNum + 1);
            }else{
                book.S_OriginalKey__c = 'B0' + String.valueOf(keyNum + 1);
            }

            keyNum += 1;
        }
    }

}