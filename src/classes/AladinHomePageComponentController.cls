/**
 * Created by 한성진 on 2022-10-18.
 */

public with sharing class AladinHomePageComponentController {

    @AuraEnabled
    public static Map<String, List<String>> getBranch(){

        Map<String, List<String>> MapBranch = new Map<String, List<String>>();

        List<AggregateResult> AggregateBranchName = [SELECT BranchName__c, Branch__c, SUM(f_MinPrice__c) TotalPrice
                                                FROM BranchBook__c
                                                GROUP BY BranchName__c, Branch__c
                                                ORDER BY BranchName__c ASC];

        for(AggregateResult ABN : AggregateBranchName){

            List<String> BranchIdAndTotalPrice = new List<String>();
            BranchIdAndTotalPrice.add(Url.getSalesforceBaseUrl().toExternalForm());
            BranchIdAndTotalPrice.add(String.valueOf(ABN.get('TotalPrice')));
            BranchIdAndTotalPrice.add(String.valueOf(ABN.get('Branch__c')));
            MapBranch.put(String.valueOf(ABN.get('BranchName__c')), BranchIdAndTotalPrice);
        }

        return MapBranch;
    }

    @AuraEnabled
    public static void refreshBook(){
        List<BranchBook__c> BranchBook= [SELECT Id FROM BranchBook__c];

        delete BranchBook;

        Integer startNum = 1;
        Integer endNum = 50;

        for(Integer i = 2; i < 30; i++){
            IF_GetDropshippingUsedBook.getBookListInfo(startNum, endNum);
            startNum = endNum;
            endNum = 50*i;
        }
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

        List<Branch__c> ListBranch = [SELECT Id, Name, TotalPrice__c FROM Branch__c];

        for(Branch__c B : ListBranch){

            StringPrice = MapBranch.get(B.Id);
            FormattingPrice = ( Decimal.valueOf(StringPrice.trim()==''?'0':StringPrice).setScale(2)).format();
            FormattedPrice = FormattingPrice.substring(0,FormattingPrice.length())+'원';
            B.TotalPrice__c = FormattedPrice;
        }

        update ListBranch;
    }

}