public with sharing class sc_AladinBatch_1_2 implements Schedulable, Database.AllowsCallouts{
    
    /*
    String CRON_EXP = '00 35 11 * * ? *';
    System.schedule('1. 지점별 재고 가져오기 배치 1_2.', CRON_EXP, new sc_AladinBatch_1_2());
    */
    public void execute(SchedulableContext sc) {

        Integer startNum = 1440;
        Integer endNum = 1470;

        for(Integer i = 50; i < 100; i++){
            IF_GetDropshippingUsedBook.getBookListInfo(startNum, endNum);
            startNum = endNum;
            endNum = 30*i;
        }

    }
}