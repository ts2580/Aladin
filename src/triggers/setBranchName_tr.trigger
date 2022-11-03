trigger setBranchName_tr on BranchBook__c (before delete ) {

    /*for(BranchBook__c BB : Trigger.new) {
        BB.BranchName__c = BB.Branch__r.Name;
    }*/

    // Apex trigger는 look up 필드값을 못 가져옴.
    // Set<id> BranchBookId = trigger.newMap.getKeySet(); -> (...id in:BranchBookId).
    // 이렇게 하느니 그냥 Flow를 쓰자.
}