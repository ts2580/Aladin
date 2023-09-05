/**
 * Created by 한성진 on 2023-09-04.
 */

public with sharing class tr_BranchBook extends TriggerHandler{
    private Map<Id, BranchBook__c> mapOld{get; set;}
    private List<BranchBook__c> listNew{get; set;}
    private List<BranchBook__c> listOld{get; set;}

    public tr_BranchBook() {
        mapOld = (Map<Id, BranchBook__c>) Trigger.oldMap;
        listNew = (List<BranchBook__c>) Trigger.new;
        listOld = (List<BranchBook__c>) Trigger.old;
    }

    public override void beforeInsert() {
        setKey(listNew);
    }

    // Before Insert Method

    //-----------------------------------------------------------------------------------------------------------
    //  내용 : BranchBook__c의 Key를 만들어주는 트리거.
    //-----------------------------------------------------------------------------------------------------------
    public static void setKey(List<BranchBook__c> listNew){

        System.debug('트리거 진입');

        // 사실 uuid가 아니라 guid임

        for(BranchBook__c obj : listNew){
            Blob b = Crypto.generateAesKey(128);
            String h = EncodingUtil.convertToHex(b);
            String uuid = h.substring(0,8)+ '-' + h.substring(8,12) + '-' + h.substring(12,16) + '-' + h.substring(16,20) + '-' + h.substring(20);

            obj.UUID__c = uuid;
        }

    }

}