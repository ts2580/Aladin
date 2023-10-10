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
    public static void refreshBook_1(Integer seq, List<BookByVolume__x> listBooks){

        List<BranchBook__c> bbv = [
                SELECT Id, Name
                FROM BranchBook__c
        ];

        delete bbv;

        List<BookByVolume__x> listSplitedBook = new List<BookByVolume__x>();

        // External Object에다가 곧바로 쓰면 Odata 리밋땜에 잠김
        // Heroku Connect를 통해 Internal Object에 쌓고, PG 트리거로 Ext 테이블에 쌓아줌
        // 그리고 Int 테이블 데이터는 지움(양방향 설정)
        // 한꺼번에 Int 테이블에 쌓으면 sfdc 용량도 부족하고(5MB!), 한 테이블에 Insert와 Del이 빡세게 일어나는것 같아서 끊어서 침

        // 비동기 메소드는 sObject 안받아. 프리미티브 타입으로 보내야함. 비동기로 쏘는 도중 데이터가 바뀌는것(무결성?) 방지
        // 따라서 Id만 set으로 보내서 다시 쿼리 하라고 하는데, 그러면 헤로쿠에서 하꺼번에 쿼리해서 가져오는 의미가 없지.
        // 바로 제이슨으로 씨리얼라이즈 해서 보내고, sObject로 디씨리얼라이즈 해서 받는다.
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

        List<BookByVolume__x> listBookByVolume = [
                SELECT ISBN13__c, Name__c, Volume__c, Seq__c, Type__c, Book__c
                FROM BookByVolume__x
                WHERE IsPurchased__c = FALSE
                AND NoNeedToBuy__c = FALSE
        ];

        return listBookByVolume;
    }

    @AuraEnabled
    public static List<BranchBookExt__x> refreshBookManual(List<BookByVolume__x> listBooks, Integer strNum, Integer endNum, Boolean isFirstTry){

        Boolean param = isFirstTry;

        List<BranchBookExt__x> listBranchBookExt = new List<BranchBookExt__x>();

        List<BookByVolume__x> listTargetBook = new List<BookByVolume__x>();

        for(Integer i = 0; i < listBooks.size(); i++){
            if(i >= strNum && i <  endNum){
                listTargetBook.add(listBooks[i]);
            }
        }

        /*if(param){
            *//*List<BranchBook__c> BranchBook= [
                    SELECT Id
                    FROM BranchBook__c
            ];
            delete BranchBook;*//*

            List<BranchBookExt__x> BranchBook= [
                    SELECT Id, Id__c
                    FROM BranchBookExt__x
            ];

            Database.deleteAsync(BranchBook);
        }*/

        listBranchBookExt = IF_GetDropshippingUsedBook.getBookListInfo(listTargetBook, strNum, endNum);

        return listBranchBookExt;

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
    public static void refreshPrice(){

        String StringPrice = null;
        String FormattingPrice = null;
        String FormattedPrice = null;

        List<BranchBookExt__x> listBranchBook = [
                SELECT Branch__c, MinPrice__c
                FROM BranchBookExt__x
        ];

        Map<String, Integer> mapTotalPric = new Map<String, Integer>();

        Integer price = 0;
        for(BranchBookExt__x obj : listBranchBook){

            price = 0;

            if(String.isNotBlank(String.valueOf(mapTotalPric.get(obj.Branch__c)))){
                price = mapTotalPric.get(obj.Branch__c);
            }

            price += Integer.valueOf(obj.MinPrice__c);

            mapTotalPric.put(obj.Branch__c, price);

        }

        List<Branch__c> ListBranch = [
                SELECT Id, Name, TotalPrice__c, TotalPriceInt__c
                FROM Branch__c
        ];

        for(Branch__c B : ListBranch){

            StringPrice = String.valueOf(mapTotalPric.get(B.Id));

            try{
                FormattingPrice = (Decimal.valueOf(StringPrice.trim()==''?'0':StringPrice).setScale(2)).format();
                FormattedPrice = FormattingPrice.substring(0,FormattingPrice.length())+'원';
                B.TotalPrice__c = FormattedPrice;
                B.TotalPriceInt__c = Integer.valueOf(StringPrice);
            }catch(Exception e){
                B.TotalPrice__c = '재고없음!';
                B.TotalPriceInt__c = 0;
            }
        }

        update ListBranch;
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