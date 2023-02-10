/**
 * Created by 한성진 on 2022-10-18.
 */

public with sharing class AladinHomePageComponentController {

    @AuraEnabled(Cacheable=true)
    public static List<Branch__c> getBranch(){

        List<Branch__c> listBranch = [SELECT Id, Name, TotalPrice__c FROM Branch__c ORDER BY TotalPriceInt__c DESC];

        return listBranch;
    }
    @AuraEnabled(Cacheable=true)
    public static List<bookByVolume__x> getBook(Id recordId){

        List<bookByVolume__x> listBookByVolume = [SELECT Name__c, IsPurchased__c, Id, Cover__c, Price__c, Volume__c
                                                  FROM bookByVolume__x
                                                  WHERE Book__c =: recordId
                                                  ORDER BY Volume__c];

        return listBookByVolume;
    }

    @AuraEnabled
    public static void deleteBook(){
        
        List<BranchBook__c> BranchBook= [SELECT Id FROM BranchBook__c];
        delete BranchBook;

    }

    @AuraEnabled
    public static void refreshBook_1(Integer startNum, Integer endNum){
        IF_GetDropshippingUsedBook.getBookListInfo(startNum, endNum);
    }

    @AuraEnabled
    public static void refreshBook_2(){

        Integer startNum = 1470;
        Integer endNum = 1500;

        for(Integer i = 51; i < 100; i++){
            IF_GetDropshippingUsedBook.getBookListInfo(startNum, endNum);
            startNum = endNum;
            endNum = 30*i;
        }
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

        List<InterfaceLog__c> InterfaceLog= [SELECT Id, StartNum__c, ENDNum__c
        FROM InterfaceLog__c
        WHERE IsRerun__c = FALSE];

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

        List<AggregateResult> AggregateBranchName = [SELECT Branch__c, SUM(f_MinPrice__c) TotalPrice
        FROM BranchBook__c
        GROUP BY Branch__c
        ORDER BY SUM(f_MinPrice__c) DESC];

        Map<Id, String> MapBranch = new Map<Id, String>();

        for(AggregateResult ABN : AggregateBranchName){
            MapBranch.put(String.valueOf(ABN.get('Branch__c')), String.valueOf(ABN.get('TotalPrice')));
        }

        List<Branch__c> ListBranch = [SELECT Id, Name, TotalPrice__c, TotalPriceInt__c FROM Branch__c];

        for(Branch__c B : ListBranch){

            StringPrice = MapBranch.get(B.Id);
            FormattingPrice = (Decimal.valueOf(StringPrice.trim()==''?'0':StringPrice).setScale(2)).format();
            FormattedPrice = FormattingPrice.substring(0,FormattingPrice.length())+'원';
            B.TotalPrice__c = FormattedPrice;
            B.TotalPriceInt__c = Integer.valueOf(StringPrice);
        }

        update ListBranch;
    }

}