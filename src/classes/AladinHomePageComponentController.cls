/**
 * Created by 한성진 on 2022-10-18.
 */

public with sharing class AladinHomePageComponentController {

    // Todo 헤로쿠에 external relationship 필드 넣어놓고, 그거 바뀌면 해당사항 반영하는지 확인하기

    @AuraEnabled(Cacheable=true)
    public static List<Branch__c> getBranch(){

        List<Branch__c> listBranch = [
                SELECT Id, Name, TotalPrice__c
                FROM Branch__c
                ORDER BY TotalPriceInt__c DESC
        ];

        return listBranch;
    }

    @AuraEnabled
    public static void refreshBook(Integer seq, List<BookByVolume__x> listBooks){

        List<BookByVolume__x> listSplitedBook = new List<BookByVolume__x>();

        for(Integer i = 0; i < listBooks.size(); i++){

            if(i >= seq*600 && i < (seq+1)*600){
                listSplitedBook.add(listBooks[i]);

                if(Math.mod(i,30) == 0){
                    IF_GetDropshippingUsedBook.getStockAsync(JSON.serialize(listSplitedBook));
                    listSplitedBook.clear();
                }
            }
        }
    }

    @AuraEnabled(Cacheable=true)
    public static List<BookByVolume__x> getBooKAll(){

        IF_Util ifu = new IF_Util();
        String url = ifu.proxyConUrl('library/bookbyvolumes/target');

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

        return listBook;
    }

    @AuraEnabled
    public static void delBook(){
        IF_Util ifu = new IF_Util();
        String url = ifu.proxyConUrl('library/bookbyvolumes/target');

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('DELETE');
        HttpResponse response = http.send(request);

        System.debug(response.getBody());
    }

    @AuraEnabled
    public static void refreshPrice(){

        IF_Util ifu = new IF_Util();
        String url = ifu.proxyConUrl('library/bookbyvolumes/pric');

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('PUT');
        HttpResponse response = http.send(request);

        System.debug(response.getBody());
    }

    @AuraEnabled(Cacheable=true)
    public static String insertBranchBook(List<BranchBookExt__x> listBranchBookExt){

        String isSuccess = '1';

        try {
            Database.insertAsync(listBranchBookExt);
        }catch (Exception e){
            isSuccess = '2';
        }


        return isSuccess;
    }

    @AuraEnabled
    public static void rerunFailedIF(){

        List<InterfaceLog__c> InterfaceLog= [
                SELECT Id, StartNum__c, ENDNum__c
                FROM InterfaceLog__c
                WHERE IsRerun__c = FALSE
        ];

        Decimal startNum = 0;
        Decimal endNum = 0;

        for(InterfaceLog__c IFG : InterfaceLog){
            startNum = IFG.StartNum__c;
            endNum = IFG.ENDNum__c;
            // IF_GetDropshippingUsedBook.getBookListInfo(startNum.intValue(),endNum.intValue());
            IFG.IsRerun__c = true;
        }

        update InterfaceLog;
    }

    @AuraEnabled
    public static void deleteIfLog(){
        List<InterfaceLog__c> InterfaceLog= [
                SELECT Id
                FROM InterfaceLog__c
        ];
        delete InterfaceLog;
    }
}