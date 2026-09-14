@IsTest
private class bookController_Test {
  @IsTest
  static void returnsNoBooksWhenDatabaseIsEmpty() {
    System.assertEquals(0, bookController.getBooks().size());
  }
}
