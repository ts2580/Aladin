/**
 * Created by HSJ on 2023-09-04.
 */

trigger BranchBook on BranchBook__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (TriggerSetting__mdt.getInstance('TriggerSetting')?.TriggerAllActive__c
            && TriggerSetting__mdt.getInstance('TriggerSetting')?.BranchBookActive__c) {
        new tr_BranchBook().run();
    }
}