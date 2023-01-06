public with sharing class sc_AladinBatch_2 implements Schedulable, Database.AllowsCallouts{

    /*
    String CRON_EXP = '00 45 11 * * ? *';
    System.schedule('2. 실패한 인터페이스 재실행 배치', CRON_EXP, new sc_AladinBatch_2());
    */
    public void execute(SchedulableContext sc) {

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


}