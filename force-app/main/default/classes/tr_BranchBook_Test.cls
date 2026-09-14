@IsTest
private class tr_BranchBook_Test {
  @IsTest
  static void assignsUuidBeforeInsert() {
    BranchBook__c branchBook = new BranchBook__c();
    tr_BranchBook.setKey(new List<BranchBook__c>{ branchBook });

    System.assertNotEquals(null, branchBook.UUID__c);
    System.assertEquals(36, branchBook.UUID__c.length());
  }
}
