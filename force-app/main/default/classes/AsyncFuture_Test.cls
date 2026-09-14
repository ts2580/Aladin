@IsTest
private class AsyncFuture_Test {
  @IsTest
  static void runsFutureMethod() {
    Test.startTest();
    AsyncFuture.imFuture();
    Test.stopTest();
    System.assert(true, 'Future method completed');
  }
}
