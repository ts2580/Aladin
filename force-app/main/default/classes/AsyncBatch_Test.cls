@IsTest
private class AsyncBatch_Test {
  @IsTest
  static void updatesContactsInBatch() {
    Contact contact = new Contact(LastName = 'Batch 대상');
    insert contact;

    Test.startTest();
    Database.executeBatch(new AsyncBatch(), 1);
    Test.stopTest();

    contact = [SELECT Phone, Fax FROM Contact WHERE Id = :contact.Id];
    System.assertEquals('1 번째 배치 테스트', contact.Phone);
    System.assertEquals('배치 테스트', contact.Fax);
  }
}
