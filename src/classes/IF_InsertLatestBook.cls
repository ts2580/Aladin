/**
 * Created by 한성진 on 2022-10-28.
 */

public with sharing class IF_InsertLatestBook {

    public static List<BookByVolume__x> insertLatestBook(String title){

        IF_Util IF_Util = new IF_Util();
        Map<String, Object> BookMap = new Map<String, Object>();
        List<BookByVolume__x> ListBooks = [
                SELECT Id, ISBN13__c, Name__c, Price__c, Cover__c, Book__c, Volume__c
                FROM BookByVolume__x
                WHERE Name__c =: title];

        for(BookByVolume__x BBV : ListBooks){

            Integer TotalVolume;

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(IF_Util.getBookInfoURL(BBV.Name__c));
            request.setMethod('GET');
            HttpResponse response = http.send(request);

            List<Object> Books = new List<Object>();
            Integer price;


            if (response.getStatusCode() == 200) {

                Map<String, Object> responseBooks = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Books = (List<Object>) responseBooks.get('item');

                TotalVolume = Books.size();
                for(Object objectBook : Books){

                    BookMap = (Map<String, Object>) objectBook;

                    String BookName = (String)BookMap.get('title');
                    if(BookName.length() > 70){
                        BookName = BookName.substring(0, 50);
                    }
                    BBV.Name__c = BookName;
                    BBV.ISBN13__c = (String) BookMap.get('isbn13');
                    price = (Integer) BookMap.get('priceSales');
                    BBV.Price__c = String.valueOf(price);

                    String NormalCover = (String) BookMap.get('cover');

                    BBV.Cover__c = NormalCover.replace('cover','cover500');
                    BBV.Volume__c = BBV.Volume__c != null ? BBV.Volume__c : 0;
                }
            }
        }
        Database.updateAsync(ListBooks);
        return ListBooks;
    }
}