/**
 * Created by 한성진 on 2022-10-28.
 */

public with sharing class IF_InsertLatestBook {

    public static void insertLatestBook(Integer StartNum, Integer ENDNum){

        IF_Util IF_Util = new IF_Util();
        Map<String, Object> BookMap = new Map<String, Object>();
        List<bookByVolume__x> ListBooks = [
                SELECT Id, isbn13__c, name__c, price__c, cover__c
                FROM bookByVolume__x
                WHERE seq__c >=: StartNum
                AND seq__c <: ENDNum];

        for(bookByVolume__x BBV : ListBooks){

            Integer TotalVolume;

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(IF_Util.getBookInfoURL(BBV.name__c));
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
                    BBV.name__c = BookName;
                    BBV.isbn13__c = (String) BookMap.get('isbn13');
                    price = (Integer) BookMap.get('priceSales');
                    BBV.price__c = String.valueOf(price);

                    String NormalCover = (String) BookMap.get('cover');

                    BBV.cover__c = NormalCover.replace('cover','cover500');
                }
            }
        }
        Database.updateAsync(ListBooks);
    }
}