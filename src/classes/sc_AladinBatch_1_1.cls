public with sharing class sc_AladinBatch_1_1 implements Schedulable, Database.AllowsCallouts{
    
    /*
    String CRON_EXP = '00 30 11 * * ? *';
    System.schedule('1. 지점별 재고 가져오기 배치 1_1.', CRON_EXP, new sc_AladinBatch_1_1());
    */
    public void execute(SchedulableContext sc) {

        List<BranchBook__c> BranchBook= [SELECT Id FROM BranchBook__c];

        delete BranchBook;

        Integer startNum = 1;
        Integer endNum = 30;

        for(Integer i = 2; i < 50; i++){
            IF_GetDropshippingUsedBook.getBookListInfo(startNum, endNum);
            startNum = endNum;
            endNum = 30*i;
        }

    }
}