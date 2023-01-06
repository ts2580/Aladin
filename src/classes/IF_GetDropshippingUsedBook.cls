/**
 * Created by SUNGJIN on 2022-10-02.
 */

public with sharing class IF_GetDropshippingUsedBook {

    @Future(Callout = true)
    public static void getBookListInfo(Integer StartNum, Integer ENDNum){

        IF_Util IF_Util = new IF_Util();
        List<InterfaceLog__c> listIFL = new List<InterfaceLog__c>();
        List<bookByVolume__x> ListBooks = new List<bookByVolume__x>();

        try {
            ListBooks = [
                SELECT ISBN13__c, Name__c, Book__c, Volume__c, Seq__c
                FROM bookByVolume__x
                WHERE IsPurchased__c = FALSE
                AND NoNeedToBuy__c = FALSE
                AND Seq__c >=: StartNum
                AND Seq__c <: ENDNum
            ];
        }catch (Exception e){
            InterfaceLog__c IFL = new InterfaceLog__c();
            IFL.StartNum__c = StartNum;
            IFL.ENDNum__c = ENDNum;
            IFL.Name = ' Seq ' + StartNum + ' ~ ' + ENDNum +'사이 중고책 정보 헤로쿠에서 받아오기 에러 발생';
            IFL.Log__c = e.getMessage();

            insert IFL;
        }

        if(!ListBooks.isEmpty()){
            List<BranchBook__c> ListBranchBook = new List<BranchBook__c>();
            List<Object> Books = new List<Object>();

            Map<String, Id> BranchMap = IF_Util.getBranch();
            Map<String, Object> aladinUsed = new Map<String, Object>();
            Map<String, Object> spaceUsed = new Map<String, Object>();
            Map<String, String> ParamMap = new Map<String, String>();

            for(bookByVolume__x BBV : ListBooks){

                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(IF_Util.getDropshippingUsedBookURL(BBV.ISBN13__c));
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
                        BBV.Volume__c = (BBV.Volume__c == null) ? 1 : BBV.Volume__c;

                        BranchBook__c BranchBook = new BranchBook__c();
                        BranchBook.Name = BBV.Name__c;
                        BranchBook.Branch__c = BranchMap.get('알라딘 직배송');
                        BranchBook.BranchName__c = '알라딘 직배송';
                        BranchBook.Book__c = BBV.Book__c;
                        BranchBook.Volume__c = BBV.Volume__c;

                        String link = (String) aladinUsed.get('link');
                        BranchBook.BookLink__c = link.replace('amp;','');

                        BranchBook.MinPrice__c = String.valueOf(minPrice);
                        ListBranchBook.add(BranchBook);
                    }

                    spaceUsed = (Map<String, Object>) spaceUsed.get('spaceUsed');

                    Integer IsThereSpaceUsed = (Integer)spaceUsed.get('itemCount');
                    Integer spaceMinPrice = (Integer)spaceUsed.get('minPrice');

                    if(IsThereSpaceUsed != 0 && IsThereSpaceUsed != null){
                        ParamMap.put('BookName', BBV.Name__c);
                        ParamMap.put('ISBN13', BBV.ISBN13__c);
                        ParamMap.put('MinPrice', String.valueOf(spaceMinPrice));
                        ParamMap.put('MasterBook', BBV.Book__c);
                        ParamMap.put('Volume', String.valueOf(BBV.Volume__c));

                        try{
                            List<BranchBook__c> spaceBranchBook = IF_GetUsedBookInfo.getUsedBookInfo(BranchMap, ParamMap);

                            for(BranchBook__c SBB : spaceBranchBook){
                                ListBranchBook.add(SBB);
                            }
                        }catch(Exception e){
                            InterfaceLog__c IFL = new InterfaceLog__c();
                            IFL.StartNum__c = BBV.Seq__c;
                            IFL.ENDNum__c = BBV.Seq__c + 1;
                            IFL.Name = '"' + BBV.Name__c + '"' + '재고 정보 가져오기 실패';
                            IFL.Log__c = e.getMessage();
                            listIFL.add(IFL);
                        }
                    }
                }
            }
            insert ListBranchBook;
            insert listIFL;
        }else{
            InterfaceLog__c IFL = new InterfaceLog__c();
            IFL.StartNum__c = StartNum;
            IFL.ENDNum__c = ENDNum;
            IFL.Name = ' Seq ' + StartNum + ' ~ ' + ENDNum +'사이 중고책 정보 알라딘에서 받아오기 에러 발생';
            insert listIFL;
        }
    }

}