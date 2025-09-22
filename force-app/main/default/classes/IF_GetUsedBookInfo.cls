/**
 * Created by SUNGJIN on 2022-10-01.
 */

public with sharing class IF_GetUsedBookInfo {

    public static List<BranchBookExt__x> getUsedBookInfo(Map<String, Id> BranchMap, Map<String, String> ParamMap) {

        IF_Util IF_Util = new IF_Util();

        List<BranchBookExt__x> ListBranchBook = new List<BranchBookExt__x>();
        List<Object> Books = new List<Object>();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(IF_Util.getUsedBookInfoURL(ParamMap.get('ISBN13')));
        request.setMethod('GET');
        HttpResponse response = http.send(request);

        BranchBookExt__x BranchBook;
        if (response.getStatusCode() == 200) {

            Map<String, Object> responseBooks = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Books = (List<Object>) responseBooks.get('itemOffStoreList');

            for(Object objectBook : Books){

                Map<String, Object> BranchDetail = (Map<String, Object>) objectBook;
                BranchBook = new BranchBookExt__x();
                BranchBook.Name__c = ParamMap.get('BookName');
                BranchBook.Branch__c = BranchMap.get((String) BranchDetail.get('offName'));
                BranchBook.BranchName__c = (String) BranchDetail.get('BookId');
                BranchBook.Book__c = ParamMap.get('MasterBook');
                BranchBook.Volume__c = Integer.valueOf(ParamMap.get('Volume'));
                
                String link = (String) BranchDetail.get('link');
                BranchBook.BookLink__c = link.replace('amp;','');

                BranchBook.MinPrice__c = ParamMap.get('MinPrice');
                ListBranchBook.add(BranchBook);
            }

        }

        return ListBranchBook;
    }

    public static List<BookDTO.Branchbook> getUsedBookInfoBU(Map<String, Id> BranchMap, Map<String, String> ParamMap) {

        IF_Util IF_Util = new IF_Util();

        List<BookDTO.Branchbook> listBranchBook = new List<BookDTO.Branchbook>();
        BookDTO.Branchbook objBranchBook;
        List<Object> Books = new List<Object>();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(IF_Util.getUsedBookInfoURL(ParamMap.get('ISBN13')));
        request.setMethod('GET');
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {

            Map<String, Object> responseBooks = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Books = (List<Object>) responseBooks.get('itemOffStoreList');

            for(Object objectBook : Books){

                Map<String, Object> BranchDetail = (Map<String, Object>) objectBook;
                objBranchBook = new BookDTO.Branchbook();
                objBranchBook.name = ParamMap.get('BookName');
                objBranchBook.branch = BranchMap.get((String) BranchDetail.get('offName'));
                objBranchBook.branchName = (String) BranchDetail.get('offName');
                objBranchBook.book = ParamMap.get('MasterBook');
                objBranchBook.volume = Integer.valueOf(ParamMap.get('Volume'));

                String link = (String) BranchDetail.get('link');
                objBranchBook.bookLink = link.replace('amp;','');

                objBranchBook.minPrice = ParamMap.get('MinPrice');
                listBranchBook.add(objBranchBook);
            }

        }

        return listBranchBook;
    }

}