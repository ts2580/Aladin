@IsTest
private class tr_Branch_Test {
  @IsTest
  static void formatsTotalPrice() {
    Branch__c branch = new Branch__c(TotalPriceInt__c = 1000);
    tr_Branch.setTotalPrc(new List<Branch__c>{ branch });

    System.assert(branch.TotalPrice__c.endsWith('원'));
  }
}
