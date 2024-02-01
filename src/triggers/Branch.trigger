/**
 * Created by 한성진 on 2023-03-21.
 */

trigger Branch on Branch__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (TriggerSetting__mdt.getInstance('TriggerSetting')?.TriggerAllActive__c
            && TriggerSetting__mdt.getInstance('TriggerSetting')?.BranchActive__c) {
        new tr_Branch().run();
    }
}