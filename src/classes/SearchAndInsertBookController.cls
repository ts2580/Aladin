/**
 * Created by 한성진 on 2023-02-16.
 */

 public with sharing class SearchAndInsertBookController {

    @AuraEnabled
    public static List<Book__c> getBooks(String title){

        String searchWord;
        List<Book__c> listBook;

        if(!String.isBlank(title)){
            searchWord = '%' + title + '%';
            listBook = [
                    SELECT Id, Name, Type__c, Cover__c, Order__c, f_Order__c
                    FROM Book__c
                    WHERE Name LIKE: searchWord
                    ORDER BY Name ASC
            ];
        }

        return listBook;
    }

    @AuraEnabled
    public static List<BookByVolume__x> getBookExt(String title){

        String searchWord = '%' + title + '%';
        List<BookByVolume__x> listBook;

        if(!String.isBlank(title) && title.length() != 18){
            listBook = [
                    SELECT Id__c, Name__c, Volume__c, Price__c, IsPurchased__c, Cover__c, Book__c, Seq__c, Type__c
                    FROM BookByVolume__x
                    WHERE Name__c LIKE: searchWord
                    ORDER BY Book__c, Volume__c ASC
            ];
        }else if(!String.isBlank(title) && title.length() == 18){
            listBook = [
                    SELECT Id__c, Name__c, Volume__c, Price__c, IsPurchased__c, Cover__c, Book__c, Seq__c, Type__c
                    FROM BookByVolume__x
                    WHERE Book__c =: title
                    ORDER BY Book__c, Volume__c ASC
            ];
        }

        return listBook;
    }

    @AuraEnabled
    public static Book__c insertBook(Book__c paramBook){

        try{
            insert paramBook;
        }catch (Exception e){
            System.debug(e.getMessage());
        }

        return paramBook;
    }

    @AuraEnabled
    public static BookByVolume__x insertBookExt(BookByVolume__x paramBook){

        try{
            Database.insertAsync(paramBook);
        }catch (Exception e){
            System.debug(e.getMessage());
        }

        return paramBook;
    }

    @AuraEnabled
    public static List<Book__c> getBookInfo(String title){
        return IF_GetBookInfo.getBookInfo(title);
    }

    @AuraEnabled
    public static List<BookByVolume__x> getBookExtInfo(String title){
        return IF_InsertLatestBook.insertLatestBook(title);
    }

    @AuraEnabled
    public static void deleteBookExt(Integer bookId){
        BookByVolume__x objBook = [SELECT Id__c FROM BookByVolume__x WHERE Id__c =: bookId];
        Database.deleteAsync(objBook);
    }

}