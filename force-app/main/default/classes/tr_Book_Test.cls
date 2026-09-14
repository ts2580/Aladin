@IsTest
private class tr_Book_Test {
  @IsTest
  static void constructsHandlerOutsideTrigger() {
    tr_Book handler = new tr_Book();
    System.assertNotEquals(null, handler);
  }
}
