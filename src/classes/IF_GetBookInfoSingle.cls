/**
 * Created by SUNGJIN on 2022-10-01.
 */

public with sharing class IF_GetBookInfoSingle {

    public static void getBookInfo(Integer Order){
        
        IF_Util IF_Util = new IF_Util();
        InterfaceLog__c IFL = new InterfaceLog__c();
        String responseError;
        Map<String, Object> BookMap = new Map<String, Object>();
        List<Book__c> ListBooks = [
                SELECT Id, Name, Type__c, Cover__c
                FROM Book__c
                WHERE f_Order__c =: Order];
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


                if(!Books.isEmpty()){

                    TotalVolume = Books.size();
                    for(Object objectBook : Books){

                        BookMap = (Map<String, Object>) objectBook;

                        bookByVolume__x BookByVolume = new bookByVolume__x();
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
                    
                    if (LB.Cover__c == Null) {
                        LB.Cover__c = ListBookByVolume[ListBookByVolume.size() - 1].cover__c;
                    }
                    LB.TotalVolume__c = String.valueOf(TotalVolume);
                }else{
                    System.debug('예외 발생!');
                    IFL.StartNum__c = Order;
                    IFL.ENDNum__c = Order;
                    IFL.Name = ' Book의 Order가 ' + Order + '인 중고책 정보 받아오기 에러 발생';

                    insert IFL;
                }
            }
        }

        update ListBooks;
        Database.insertAsync(ListBookByVolume);
    }
}