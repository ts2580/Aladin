/**
 * Created by trsty on 24. 6. 5..
 */

public with sharing class bookController {

    @AuraEnabled
    public static List<Book__c> getBooks(){
        return [
                SELECT Id, Name, Cover__c, Type__c, Author__c, Description__c, Order__c,
                        CreatedDate, CreatedById, LastModifiedDate
                FROM Book__c
                WHERE Type__c IN ('교양', '소설', '시')
        ];
    }

}