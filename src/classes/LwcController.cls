/**
 * Created by 한성진 on 2023-09-27.
 */

public with sharing class LwcController {

    public class BookByVolume{
        @AuraEnabled
        public String  Id;
        @AuraEnabled
        public String  bookUrl;
        @AuraEnabled
        public String  title;
        @AuraEnabled
        public Boolean isPurchased;
        @AuraEnabled
        public String  price;
        @AuraEnabled
        public String  volume;
        @AuraEnabled
        public String  bookCoverUrl;

        public BookByVolume(BookByVolume__x obj, String url){

            String FormattingPrice = (Decimal.valueOf(obj.Price__c.trim()==''?'0':obj.Price__c).setScale(2)).format();
            String FormattedPrice = FormattingPrice.substring(0,FormattingPrice.length())+'원';

            this.Id = obj.Id;
            this.bookUrl = url + obj.Id;
            this.title = obj.Name__c;
            this.isPurchased = obj.IsPurchased__c;
            this.price = FormattedPrice;
            this.volume = obj.Volume__c + '권';
            this.bookCoverUrl = obj.Cover__c;
        }
    }

    @AuraEnabled(Cacheable=true)
    public static List<BookByVolume> getBook(Id recordId){

        List<BookByVolume> listBBV = new List<BookByVolume>();

        List<BookByVolume__x> listBookByVolume = [
                SELECT Name__c, IsPurchased__c, Id, Cover__c, Price__c, Volume__c, Book__c, Type__c, Description__c
                FROM BookByVolume__x
                WHERE Book__c =: recordId
                ORDER BY Volume__c
        ];

        BookByVolume objBBV;
        String url = Url.getOrgDomainUrl().toExternalForm() + '/';
        for(BookByVolume__x obj : listBookByVolume){
            objBBV = new BookByVolume(obj, url);
            listBBV.add(objBBV);
        }

        System.debug(listBBV);

        return listBBV;
    }

    @AuraEnabled(Cacheable=true)
    public static List<BookByVolume__x> getBook2(Id recordId){

        List<BookByVolume__x> listBookByVolume = [
                SELECT Name__c, IsPurchased__c, Id, Cover__c, Price__c, Volume__c, Book__c, Type__c, Description__c
                FROM BookByVolume__x
                WHERE Book__c =: recordId
                ORDER BY Volume__c
        ];

        return listBookByVolume;
    }

    public class UsedBook{
        @AuraEnabled
        public String  Id;
        @AuraEnabled
        public String  title;
        @AuraEnabled
        public Integer volume;
        @AuraEnabled
        public String  bookUrl;
        @AuraEnabled
        public String  bookByUrl;
        @AuraEnabled
        public String  bookName;
        @AuraEnabled
        public String  price;
        @AuraEnabled
        public String  link;

        public UsedBook(BranchBookExt__x obj, String url){

            String FormattingPrice = (Decimal.valueOf(obj.MinPrice__c.trim()==''?'0':obj.MinPrice__c).setScale(2)).format();
            String FormattedPrice = FormattingPrice.substring(0,FormattingPrice.length())+'원';

            this.Id = obj.Id;
            this.title = obj.Name__c;
            this.volume = Integer.valueOf(obj.Volume__c);
            this.bookUrl = url + obj.Book__c;
            this.bookByUrl = url + obj.BranchName__c;
            this.bookName = obj.Book__r.Name;
            this.price = FormattedPrice;
            this.link = obj.BookLink__c;
        }
    }

    @AuraEnabled(Cacheable=true)
    public static List<UsedBook> getBranchBook(Id recordId){

        List<UsedBook> listUsedBook = new List<UsedBook>();

        List<BranchBookExt__x> listBranchBookX = [
                SELECT Name__c, Volume__c, Book__c, MinPrice__c, BookLink__c, Book__r.Name, BranchName__c
                FROM BranchBookExt__x
                WHERE Branch__c =: recordId
                ORDER BY Name__c
        ];

        UsedBook objUsedBook;
        String url = Url.getOrgDomainUrl().toExternalForm() + '/';
        for(BranchBookExt__x obj : listBranchBookX){
            objUsedBook = new UsedBook(obj, url);
            listUsedBook.add(objUsedBook);
        }

        return listUsedBook;
    }

}