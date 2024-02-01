/**
 * Created by 한성진 on 2023-03-22.
 */

public with sharing class tr_Branch extends TriggerHandler{
    private Map<Id, Branch__c> mapOld{get; set;}
    private List<Branch__c> listNew{get; set;}
    private List<Branch__c> listOld{get; set;}

    public tr_Branch() {
        mapOld = (Map<Id, Branch__c>) Trigger.oldMap;
        listNew = (List<Branch__c>) Trigger.new;
        listOld = (List<Branch__c>) Trigger.old;
    }

    public override void beforeUpdate() {
        setTotalPrc(listNew);
    }

    /************************************************************************************
    *  Before update Method
    *************************************************************************************/
    //-----------------------------------------------------------------------------------------------------------
    //  내용 : 지점별 재고 총액 글자 예쁘게 표시해주기
    //-----------------------------------------------------------------------------------------------------------
    public static void setTotalPrc(List<Branch__c> listNew){

        String StringPrice = null;
        String FormattingPrice = null;
        String FormattedPrice = null;

        for(Branch__c obj : listNew){

            StringPrice = String.valueOf(obj.TotalPriceInt__c);

            FormattingPrice = (Decimal.valueOf(StringPrice.trim()==''?'0':StringPrice).setScale(2)).format();
            FormattedPrice = FormattingPrice.substring(0,FormattingPrice.length())+'원';
            obj.TotalPrice__c = FormattedPrice;
        }

    }

}