@IsTest
private class sc_AladinBatch_3_Test {
  @IsTest
  static void handlesBranchWithoutStock() {
    Branch__c branch = new Branch__c(Name = '테스트 지점');
    insert branch;

    new sc_AladinBatch_3().execute(null);

    branch = [
      SELECT TotalPrice__c, TotalPriceInt__c
      FROM Branch__c
      WHERE Id = :branch.Id
    ];
    System.assertEquals(0, branch.TotalPriceInt__c);
    System.assert(branch.TotalPrice__c.endsWith('원'));
  }
}
