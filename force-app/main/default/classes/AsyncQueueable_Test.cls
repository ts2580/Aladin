@IsTest
private class AsyncQueueable_Test {
  @IsTest
  static void updatesQueuedContacts() {
    Contact contact = new Contact(LastName = 'Queueable 대상');
    insert contact;

    Test.startTest();
    System.enqueueJob(new AsyncQueueable(new List<Contact>{ contact }, 1));
    Test.stopTest();

    contact = [SELECT Phone, Fax FROM Contact WHERE Id = :contact.Id];
    System.assertEquals('1 번째 배치 테스트', contact.Phone);
    System.assertEquals('Queueable 테스트', contact.Fax);
  }
}
