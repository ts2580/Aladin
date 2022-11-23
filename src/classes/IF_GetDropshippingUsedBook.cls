/**
 * Created by SUNGJIN on 2022-10-02.
 */

public with sharing class IF_GetDropshippingUsedBook {

    @Future(Callout = true)
    public static void getBookListInfo(Integer StartNum, Integer ENDNum){

        IF_Util IF_Util = new IF_Util();

        List<bookByVolume__x> ListBooks = [
                SELECT isbn13__c, name__c, book__c
                FROM bookByVolume__x
                WHERE ispurched__c = FALSE
                AND seq__c >=: StartNum
                AND seq__c <: ENDNum];
        List<BranchBook__c> ListBranchBook = new List<BranchBook__c>();
        List<Object> Books = new List<Object>();

        Map<String, Id> BranchMap = IF_Util.getBranch();
        Map<String, Object> aladinUsed = new Map<String, Object>();
        Map<String, Object> spaceUsed = new Map<String, Object>();
        Map<String, String> ParamMap = new Map<String, String>();

        for(bookByVolume__x BBV : ListBooks){

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(IF_Util.getDropshippingUsedBookURL(BBV.isbn13__c));
            request.setMethod('GET');
            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {

                Map<String, Object> responseBooks = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Books = (List<Object>) responseBooks.get('item');

                aladinUsed = (Map<String, Object>) Books[0];
                aladinUsed = (Map<String, Object>) aladinUsed.get('subInfo');
                aladinUsed = (Map<String, Object>) aladinUsed.get('usedList');
                spaceUsed = aladinUsed;

                aladinUsed = (Map<String, Object>) aladinUsed.get('aladinUsed');

                Integer IsDropShipping = (Integer)aladinUsed.get('itemCount');
                Integer minPrice = (Integer)aladinUsed.get('minPrice');

                if(IsDropShipping != 0 && IsDropShipping != null){

                    BranchBook__c BranchBook = new BranchBook__c();
                    BranchBook.Name = BBV.name__c;
                    BranchBook.Branch__c = BranchMap.get('알라딘 직배송');
                    BranchBook.BranchName__c = '알라딘 직배송';
                    BranchBook.Book__c = BBV.book__c;

                    String link = (String) aladinUsed.get('link');
                    BranchBook.BookLink__c = link.replace('amp;','');

                    BranchBook.MinPrice__c = String.valueOf(minPrice);
                    ListBranchBook.add(BranchBook);
                }

                spaceUsed = (Map<String, Object>) spaceUsed.get('spaceUsed');

                Integer IsThereSpaceUsed = (Integer)spaceUsed.get('itemCount');
                Integer spaceMinPrice = (Integer)spaceUsed.get('minPrice');

                if(IsThereSpaceUsed != 0 && IsThereSpaceUsed != null){
                    ParamMap.put('BookName', BBV.name__c);
                    ParamMap.put('ISBN13', BBV.isbn13__c);
                    ParamMap.put('MinPrice', String.valueOf(spaceMinPrice));
                    ParamMap.put('MasterBook', BBV.book__c);
                    List<BranchBook__c> spaceBranchBook = IF_GetUsedBookInfo.getUsedBookInfo(BranchMap, ParamMap);

                    for(BranchBook__c SBB : spaceBranchBook){
                        ListBranchBook.add(SBB);
                    }
                }


            }
        }

        insert ListBranchBook;
    }

}