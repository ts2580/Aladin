public with sharing class sc_AladinBatch_3 implements Schedulable, Database.AllowsCallouts{

    /*
    String CRON_EXP = '00 04 12 * * ? *';
    System.schedule('3. 지점별 재고 총액 새로고침.', CRON_EXP, new sc_AladinBatch_3());
    */
    public void execute(SchedulableContext sc) {

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
}