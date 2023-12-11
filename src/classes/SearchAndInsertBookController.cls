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
                    SELECT Id__c, Name__c, Volume__c, Price__c, Link__c,
                            IsPurchased__c, Cover__c, Seq__c, Book__c, Type__c, Description__c
                    FROM BookByVolume__x
                    WHERE Name__c LIKE: searchWord
                    ORDER BY Book__c, Volume__c DESC
            ];
        }else if(!String.isBlank(title) && title.length() == 18){
            listBook = [
                    SELECT Id__c, Name__c, Volume__c, Price__c, Link__c,
                            IsPurchased__c, Cover__c, Seq__c, Book__c, Type__c, Description__c
                    FROM BookByVolume__x
                    WHERE Book__c =: title
                    ORDER BY Book__c, Volume__c DESC
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
     public static String setBook(String title){

         String query =
                 'SELECT Id, Name ' +
                 'FROM Book__c ' +
                 'WHERE Name LIKE ' + '\'' + title.substring(0, title.length()-4) +'%\'';

         List<Book__c> listBook = Database.query(query);

         return listBook[0].Id;
     }

    @AuraEnabled
    public static BookByVolume__x insertBookExt(BookByVolume__x paramBook){

        try{
            Book__c b = [
                    SELECT Id, Type__c, TotalVolume__c
                    FROM Book__c
                    WHERE Id =: paramBook.Book__c
            ];

            paramBook.Type__c = b.Type__c;

            if(String.isBlank(String.valueOf(paramBook.Volume__c))){
                paramBook.Volume__c = Integer.valueOf(b.TotalVolume__c) + 1;
            }

            b.TotalVolume__c = String.valueOf(Integer.valueOf(b.TotalVolume__c) + 1);

            update b;

            System.debug('진입');
            System.debug(b);

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
     public static List<BookByVolume__x> getLatestBook(){

         List<BookByVolume__x> ListBooks = [
                 SELECT Id, ISBN13__c, Name__c, Price__c, Cover__c, Volume__c, Book__c, Type__c, Description__c, Link__c
                 FROM BookByVolume__x
                 WHERE IsPurchased__c = FALSE
                 AND NoNeedToBuy__c = FALSE
                 ORDER BY Id DESC
                 LIMIT 100
         ];

         return ListBooks;
     }

    @AuraEnabled
    public static void deleteBookExt(Integer bookId){
        BookByVolume__x objBook = [
                SELECT Id__c
                FROM BookByVolume__x
                WHERE Id__c =: bookId
        ];
        Database.deleteAsync(objBook);
    }

}