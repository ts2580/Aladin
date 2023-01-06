/**
 * Created by SUNGJIN on 2022-10-01.
 */

public with sharing class IF_GetBookInfo {

    public static void getBookInfo(Integer StartNum, Integer ENDNum){
        
        IF_Util IF_Util = new IF_Util();
        Map<String, Object> BookMap = new Map<String, Object>();
        List<Book__c> ListBooks = [
                SELECT Id, Name, Type__c, Cover__c
                FROM Book__c
                WHERE f_Order__c >=: StartNum
                AND f_Order__c <: ENDNum];
        List<bookbyvolume__x> ListBookByVolume = new List<bookbyvolume__x>();

        for(Book__c LB : ListBooks){

            Integer TotalVolume;

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(IF_Util.getBookInfoURL(LB.Name));
            request.setMethod('GET');
            HttpResponse response = http.send(request);

            List<Object> Books = new List<Object>();
            Integer price;


            if (response.getStatusCode() == 200) {

                Map<String, Object> responseBooks = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Books = (List<Object>) responseBooks.get('item');
                
                
                System.debug(Books);


                if(Books.isEmpty()){
                    LB.HasNoResult__c = true;
                }else{
                    TotalVolume = Books.size();
                    for(Object objectBook : Books){

                        BookMap = (Map<String, Object>) objectBook;

                        bookbyvolume__x BookByVolume = new bookbyvolume__x();
                        String BookName = (String)BookMap.get('title');
                        if(BookName.length() > 70){
                            BookName = BookName.substring(0, 50);
                        }
                        BookByVolume.name__c = BookName;
                        BookByVolume.isbn13__c = (String) BookMap.get('isbn13');
                        price = (Integer) BookMap.get('priceSales');
                        BookByVolume.price__c = String.valueOf(price);

                        String NormalCover = (String) BookMap.get('cover');

                        BookByVolume.cover__c = NormalCover.replace('cover','cover500');
                        BookByVolume.book__c = LB.Id;
                        BookByVolume.type__c = LB.Type__c;
                        BookByVolume.volume__c = Integer.valueOf(TotalVolume);
                        TotalVolume--;                            

                        ListBookByVolume.add(BookByVolume);
                    }

                    LB.Cover__c = ListBookByVolume[ListBookByVolume.size() - 1].cover__c;
                }
            }
        }

        update ListBooks;
        Database.insertAsync(ListBookByVolume);
    }
}