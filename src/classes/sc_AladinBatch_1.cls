/**
 * Created by 한성진 on 2023-03-17.
 */

public with sharing class sc_AladinBatch_1 implements Schedulable, Database.AllowsCallouts{

    /*
    String CRON_EXP = '00 00 12 * * ? *';
    System.schedule('1. 지점별 재고 가져오기 배치 1_1.', CRON_EXP, new sc_AladinBatch_1());
    */
    public void execute(SchedulableContext sc) {

        List<BranchBook__c> BranchBook= [SELECT Id FROM BranchBook__c];

        delete BranchBook;

        AladinHomePageComponentController.refreshBook_1();
    }

}