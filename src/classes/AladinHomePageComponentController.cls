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

    @AuraEnabled(Cacheable=true)
    public static List<BookByVolume__x> getBook(Id recordId){

        List<BookByVolume__x> listBookByVolume = [
                SELECT Name__c, IsPurchased__c, Id, Cover__c, Price__c, Volume__c, Book__c, Type__c
                FROM BookByVolume__x
                WHERE Book__c =: recordId
                ORDER BY Volume__c
        ];

        return listBookByVolume;
    }

    @AuraEnabled
    public static void refreshBook_1(){

        List<BranchBook__c> BranchBook= [
                SELECT Id
                FROM BranchBook__c
        ];
        delete BranchBook;

        Integer startNum = 1;
        Integer endNum = 30;

        for(Integer i = 2; i < 52; i++){
            IF_GetDropshippingUsedBook.getBookListInfo(startNum, endNum);
            startNum = endNum;
            endNum = 30*i;
        }
    }

    @AuraEnabled
    public static void refreshBookManual(Integer strNum, Integer endNum, Boolean isFirstTry){

        Boolean param = isFirstTry;

        if(param){
            List<BranchBook__c> BranchBook= [
                    SELECT Id
                    FROM BranchBook__c
            ];
            delete BranchBook;
        }

        IF_GetDropshippingUsedBook.getBookListInfo(strNum, endNum);
    }

    @AuraEnabled
    public static void refreshBook_3(){

        Integer startNum = 2970;
        Integer endNum = 3000;

        for(Integer i = 101; i < 150; i++){
            IF_GetDropshippingUsedBook.getBookListInfo(startNum, endNum);
            startNum = endNum;
            endNum = 30*i;
        }
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
            IF_GetDropshippingUsedBook.getBookListInfo(startNum.intValue(),endNum.intValue());
            IFG.IsRerun__c = true;
        }

        update InterfaceLog;
    }

    @AuraEnabled
    public static void refreshPrice(){

        String StringPrice = null;
        String FormattingPrice = null;
        String FormattedPrice = null;

        List<AggregateResult> AggregateBranchName = [
                SELECT Branch__c, SUM(f_MinPrice__c) TotalPrice
                FROM BranchBook__c
                GROUP BY Branch__c
                ORDER BY SUM(f_MinPrice__c) DESC
        ];

        Map<Id, String> MapBranch = new Map<Id, String>();

        for(AggregateResult ABN : AggregateBranchName){
            MapBranch.put(String.valueOf(ABN.get('Branch__c')), String.valueOf(ABN.get('TotalPrice')));
        }

        List<Branch__c> ListBranch = [
                SELECT Id, Name, TotalPrice__c, TotalPriceInt__c
                FROM Branch__c
        ];

        for(Branch__c B : ListBranch){

            StringPrice = MapBranch.get(B.Id);
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