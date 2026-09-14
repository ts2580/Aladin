@IsTest
private class AsyncCursor_Test {
  @IsTest
  static void initializesCursorJob() {
    Contact contact = new Contact(LastName = 'Cursor 대상');
    insert contact;
    Database.Cursor cursor = Database.getCursor(
      'SELECT Id FROM Contact ORDER BY Id'
    );
    AsyncCursor job = new AsyncCursor(cursor);
    System.assertNotEquals(null, job);
  }
}
