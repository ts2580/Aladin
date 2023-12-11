/**
 * Created by SUNGJIN on 2022-10-01.
 */

public with sharing class IF_GetBookInfo {

    public static List<Book__c> getBookInfo(String title){
        
        IF_Util IF_Util = new IF_Util();
        InterfaceLog__c IFL = new InterfaceLog__c();
        Map<String, Object> BookMap = new Map<String, Object>();
        List<Book__c> ListBooks = [
                SELECT Id, Name, Type__c, Cover__c
                FROM Book__c
                WHERE Name =: title
        ];
        List<BookByVolume__x> ListBookByVolume = new List<BookByVolume__x>();

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

                        BookByVolume__x BookByVolume = new BookByVolume__x();
                        String BookName = (String)BookMap.get('title');
                        if(BookName.length() > 70){
                            BookName = BookName.substring(0, 50);
                        }
                        BookByVolume.Name__c = BookName;
                        BookByVolume.ISBN13__c = (String) BookMap.get('isbn13');
                        price = (Integer) BookMap.get('priceSales');
                        BookByVolume.Price__c = String.valueOf(price);

                        String NormalCover = (String) BookMap.get('cover');

                        BookByVolume.Cover__c = NormalCover.replace('cover','cover500');
                        BookByVolume.Book__c = LB.Id;
                        BookByVolume.Type__c = LB.Type__c;
                        BookByVolume.Volume__c = Integer.valueOf(TotalVolume);
                        BookByVolume.Description__c = String.valueOf(BookMap.get('description')).abbreviate(1000);          // 설명
                        BookByVolume.Link__c = (String) BookMap.get('link');                        // 새 책 구매 링크
                        BookByVolume.PubDate__c = Date.valueOf((String) BookMap.get('pubDate'));    // 출간일
                        BookByVolume.Author__c = (String) BookMap.get('author');                    // 작가

                        TotalVolume--;

                        ListBookByVolume.add(BookByVolume);
                    }
                    
                    if (LB.Cover__c == null) {
                        LB.Cover__c = ListBookByVolume[ListBookByVolume.size() - 1].Cover__c;
                    }
                    LB.TotalVolume__c = String.valueOf(TotalVolume);
                }else{
                    System.debug('예외 발생!');
                    IFL.Name = ' title 중고책 정보 받아오기 에러 발생';

                    insert IFL;
                }
            }
        }

        update ListBooks;
        Database.insertAsync(ListBookByVolume);
        return ListBooks;
    }
}