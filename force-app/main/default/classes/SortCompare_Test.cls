@IsTest
private class SortCompare_Test {
  @IsTest
  static void comparesExternalBranchBooksByName() {
    SortCompare first = new SortCompare(new BranchBookExt__x(Name__c = '가'));
    SortCompare second = new SortCompare(new BranchBookExt__x(Name__c = '나'));

    System.assertEquals(-1, first.compareTo(second));
    System.assertEquals(1, second.compareTo(first));
    System.assertEquals(0, first.compareTo(first));
  }
}
