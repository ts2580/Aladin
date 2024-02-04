/**
    * Created by 한성진 on 2023-02-16.
    */

public with sharing class SearchAndInsertBookController {

    @AuraEnabled
    public static List<BookByVolume__x> getBookExt(String title){

        IF_Util ifu = new IF_Util();
        String url = ifu.proxyConUrl('library/bookbyvolume/info?title=') + EncodingUtil.urlEncode(title, 'UTF-8');

        List<BookByVolume__x> listBook = new List<BookByVolume__x>();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('GET');
        HttpResponse response = http.send(request);

        if(response.getStatusCode() == 200) {
            List<BookDTO.BookByVolume> listBBV = (List<BookDTO.BookByVolume>) JSON.deserialize(response.getBody(), List<BookDTO.BookByVolume>.class);
            BookByVolume__x objBook;

            for(BookDTO.BookByVolume obj : listBBV){
                objBook = new BookByVolume__x();
                objBook.Seq__c = obj.seq;
                objBook.Book__c = obj.book;
                objBook.Cover__c = obj.cover;
                objBook.ISBN13__c = obj.isbn13;
                objBook.Price__c = obj.price;
                objBook.IsPurchased__c = obj.ispurchased;
                objBook.Name__c = obj.name;
                objBook.Type__c = obj.type;
                objBook.Volume__c = obj.volume;
                objBook.NoNeedToBuy__c = obj.noneedtobuy;
                objBook.Id__c = obj.id;
                objBook.ISBN__c = obj.isbn;
                objBook.Description__c = obj.description;
                objBook.Link__c = obj.link;
                objBook.PubDate__c = Datetime.valueOf(obj.pubdate);
                objBook.Author__c = obj.author;
                listBook.add(objBook);
            }
        }

        System.debug(JSON.serialize(listBook));

        return listBook;
    }

    @AuraEnabled
    public static List<BookByVolume__x> getLatestBook(){

        IF_Util ifu = new IF_Util();
        String url = ifu.proxyConUrl('library/bookbyvolumes/latest');

        List<BookByVolume__x> listBook = new List<BookByVolume__x>();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('GET');
        HttpResponse response = http.send(request);

        // todo IsPurchased__c = FALSE AND NoNeedToBuy__c = FALSE 인것만 가져오기

        if(response.getStatusCode() == 200) {

            List<BookDTO.BookByVolume> listBBV = (List<BookDTO.BookByVolume>) JSON.deserialize(response.getBody(), List<BookDTO.BookByVolume>.class);
            BookByVolume__x objBook;

            for(BookDTO.BookByVolume obj : listBBV){
                objBook = new BookByVolume__x();
                objBook.Seq__c = obj.seq;
                objBook.Book__c = obj.book;
                objBook.Cover__c = obj.cover;
                objBook.ISBN13__c = obj.isbn13;
                objBook.Price__c = obj.price;
                objBook.IsPurchased__c = obj.isPurchased;
                objBook.Name__c = obj.name;
                objBook.Type__c = obj.type;
                objBook.Volume__c = obj.volume;
                objBook.NoNeedToBuy__c = obj.noneedToBuy;
                objBook.Id__c = obj.id;
                objBook.ISBN__c = obj.isbn;
                objBook.Description__c = obj.description;
                objBook.Link__c = obj.link;
                objBook.PubDate__c = Datetime.valueOf(obj.pubDate);
                objBook.Author__c = obj.author;
                listBook.add(objBook);
            }
        }

        return listBook;
    }
    @AuraEnabled
    public static BookByVolume__x insertBookExt(BookByVolume__x paramBook){
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

        List<BookDTO.BookByVolume> listBook = new List<BookDTO.BookByVolume>();

        BookDTO.BookByVolume objBook = new BookDTO.BookByVolume();
        objBook.volume = Integer.valueOf(paramBook.Volume__c);
        objBook.type = b.Type__c;
        objBook.name = paramBook.Name__c.replace(' ', ' ');
        objBook.book = paramBook.Book__c;
        objBook.isPurchased = paramBook.IsPurchased__c;
        listBook.add(objBook);

        IF_Util ifu = new IF_Util();
        String url = ifu.proxyConUrl('library/bookbyvolumes');

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(JSON.serialize(listBook));
        HttpResponse response = http.send(request);

        if(response.getStatusCode() == 200) {

            url = ifu.proxyConUrl('library/bookbyvolume/info?title=') + EncodingUtil.urlEncode(objBook.name, 'UTF-8');

            http = new Http();
            request = new HttpRequest();
            request.setEndpoint(url);
            request.setMethod('GET');
            response = http.send(request);

            if(response.getStatusCode() == 200) {
                List<BookDTO.BookByVolume> listBBV = (List<BookDTO.BookByVolume>) JSON.deserialize(response.getBody(), List<BookDTO.BookByVolume>.class);
                update b;
                paramBook.Id__c = listBBV[0].id;
            }
        }

        return paramBook;
    }
    @AuraEnabled
    public static List<BookByVolume__x> getBookExtInfo(BookByVolume__x objBook){

        // 아니 왜 PG에서 Date 불러올 떈 Datetime으로 오는거야
        // 근데 넣을때 받은 그대로 넣으면 터지잖아 슈발
        // 아니 슈발 받을때부터 Datetime이었구나. 날 잡아서 바꾸자

        List<BookDTO.BookByVolume> listBooks = new List<BookDTO.BookByVolume>();
        List<BookByVolume__x> listBBV = new List<BookByVolume__x>();

        BookDTO.BookByVolume paramBook = IF_InsertLatestBook.insertLatestBook(objBook);
        listBooks.add(paramBook);

        IF_Util ifu = new IF_Util();
        String url = ifu.proxyConUrl('library/bookbyvolumes');

        // todo 애는 위에서 넣은거 업데이트!
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('PUT');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(JSON.serialize(listBooks));
        HttpResponse response = http.send(request);

        if(response.getStatusCode() == 200) {

            url = ifu.proxyConUrl('library/bookbyvolume/info?title=') + EncodingUtil.urlEncode(objBook.Name__c, 'UTF-8');

            http = new Http();
            request = new HttpRequest();
            request.setEndpoint(url);
            request.setMethod('GET');
            response = http.send(request);

            System.debug(JSON.serialize(listBooks));
            System.debug(response.getBody());

            listBooks = (List<BookDTO.BookByVolume>) JSON.deserialize(response.getBody(), List<BookDTO.BookByVolume>.class);
            paramBook = listBooks[0];
            objBook.Seq__c = paramBook.seq;
            objBook.Book__c = paramBook.book;
            objBook.Cover__c = paramBook.cover;
            objBook.ISBN13__c = paramBook.isbn13;
            objBook.Price__c = paramBook.price;
            objBook.IsPurchased__c = paramBook.isPurchased;
            objBook.Name__c = paramBook.name;
            objBook.Type__c = paramBook.type;
            objBook.Volume__c = paramBook.volume;
            objBook.NoNeedToBuy__c = paramBook.noneedToBuy;
            objBook.Id__c = paramBook.id;
            objBook.ISBN__c = paramBook.isbn;
            objBook.Description__c = paramBook.description;
            objBook.Link__c = paramBook.link;
            objBook.PubDate__c = Datetime.valueOf(paramBook.pubDate);
            objBook.Author__c = paramBook.author;
            listBBV.add(objBook);
        }

        return listBBV;
    }
    @AuraEnabled
    public static void deleteBookExt(Integer bookId){

        IF_Util ifu = new IF_Util();
        String url = ifu.proxyConUrl('library/bookbyvolume/basic');

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('DELETE');
        request.setBody(JSON.serialize(bookId));
        HttpResponse response = http.send(request);

    }

    @AuraEnabled
    public static BookByVolume__x insertBookExtBack(BookByVolume__x paramBook){
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
    public static void deleteBookExtBack(Integer bookId){
        BookByVolume__x objBook = [
                SELECT Id__c
                FROM BookByVolume__x
                WHERE Id__c =: bookId
        ];
        Database.deleteAsync(objBook);
    }

    @AuraEnabled
    public static List<BookByVolume__x> getLatestBookBak(){

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
    public static List<BookByVolume__x> getBookExtBack(String title){

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
    public static List<Book__c> getBookInfo(String title){
        return IF_GetBookInfo.getBookInfo(title);
    }

    @AuraEnabled
    public static String setBookExt(BookByVolume__x objBook){

        String returnParam = null;

        List<BookDTO.BookByVolume> listBooks = new List<BookDTO.BookByVolume>();

        BookDTO.BookByVolume paramBook = new BookDTO.BookByVolume();
        paramBook.seq = Integer.valueOf(objBook.Id__c);
        paramBook.book = objBook.Book__c;
        paramBook.cover = objBook.Cover__c;
        paramBook.isbn13 = objBook.ISBN13__c;
        paramBook.price = objBook.Price__c;
        paramBook.ispurchased = objBook.IsPurchased__c;
        paramBook.name = objBook.Name__c;
        paramBook.type = objBook.Type__c;
        paramBook.volume = Integer.valueOf(objBook.Volume__c);
        paramBook.noneedtobuy = objBook.NoNeedToBuy__c;
        paramBook.id = Integer.valueOf(objBook.Id__c);
        paramBook.isbn = objBook.ISBN__c;
        paramBook.description = objBook.Description__c;
        paramBook.link = objBook.Link__c;
        paramBook.pubdate = objBook.PubDate__c;
        paramBook.author = objBook.Author__c;
        listBooks.add(paramBook);

        String param = JSON.serialize(listBooks, true);

        System.debug(param);

        IF_Util ifu = new IF_Util();
        String url = ifu.proxyConUrl('library/bookbyvolumes');

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('PUT');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(param);
        HttpResponse response = http.send(request);

        if(response.getStatusCode() == 200) {
            System.debug(response.getBody());
            returnParam = '성공';
        }

        return returnParam;
    }





}