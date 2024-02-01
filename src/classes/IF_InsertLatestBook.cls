/**
 * Created by 한성진 on 2022-10-28.
 */

public with sharing class IF_InsertLatestBook {

    public static BookDTO.BookByVolume insertLatestBook(BookByVolume__x book){

        IF_Util IF_Util = new IF_Util();
        Map<String, Object> BookMap = new Map<String, Object>();

        String url = IF_Util.getBookInfoURL(book.Name__c);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('GET');
        HttpResponse response = http.send(request);

        List<Object> Books = new List<Object>();
        Integer price;

        BookDTO.BookByVolume objBook = new BookDTO.BookByVolume();
        if (response.getStatusCode() == 200) {

            Map<String, Object> responseBooks = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

            Books = (List<Object>) responseBooks.get('item');

            for(Object objectBook : Books){

                BookMap = (Map<String, Object>) objectBook;

                String BookName = (String)BookMap.get('title');
                if(BookName.length() > 70){
                    BookName = BookName.substring(0, 50);
                }

                objBook.id = Integer.valueOf(book.Id__c);
                objBook.name = BookName;
                objBook.isbn13 = (String) BookMap.get('isbn13');
                price = (Integer) BookMap.get('priceSales');
                objBook.price = String.valueOf(price);
                objBook.type = book.Type__c;
                objBook.volume = Integer.valueOf(book.Volume__c);
                objBook.book = book.Book__c;

                objBook.isPurchased = book.IsPurchased__c == false ? false : true;
                objBook.noneedToBuy = book.NoNeedToBuy__c == false ? false : true;

                String NormalCover = (String) BookMap.get('cover');

                objBook.cover = NormalCover.replace('cover','cover500');
                objBook.volume = objBook.volume != null ? objBook.volume : 0;
                objBook.description = String.valueOf(BookMap.get('description')).abbreviate(1000);      // 설명
                objBook.link = (String) BookMap.get('link');                                            // 새 책 구매 링크
                objBook.pubDate = Date.valueOf((String) BookMap.get('pubDate'));                        // 출간일
                objBook.author = (String) BookMap.get('author');                                        // 작가
            }
        }

        return objBook;
    }

    private List<BookByVolume__x> insertLatestBookBack(String title){

        IF_Util IF_Util = new IF_Util();
        Map<String, Object> BookMap = new Map<String, Object>();
        List<BookByVolume__x> ListBooks = [
                SELECT Id, ISBN13__c, Name__c, Price__c, Cover__c, Volume__c, Book__c, Type__c
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
                    BBV.Description__c = String.valueOf(BookMap.get('description')).abbreviate(1000);          // 설명
                    BBV.Link__c = (String) BookMap.get('link');                        // 새 책 구매 링크
                    BBV.PubDate__c = Datetime.valueOf((String) BookMap.get('pubDate'));    // 출간일
                    BBV.Author__c = (String) BookMap.get('author');                    // 작가
                }
            }
        }
        Database.updateAsync(ListBooks);
        return ListBooks;
    }

}