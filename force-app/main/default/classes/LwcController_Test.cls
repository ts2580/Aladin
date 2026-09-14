@IsTest
private class LwcController_Test {
  @IsTest
  static void formatsBookByVolumeForLwc() {
    BookByVolume__x source = new BookByVolume__x(
      Name__c = '테스트 책',
      Price__c = '12000',
      Volume__c = 3,
      IsPurchased__c = false,
      Cover__c = 'https://example.com/cover.jpg'
    );

    LwcController.BookByVolume result = new LwcController.BookByVolume(
      source,
      'https://example.com/'
    );

    System.assertEquals('테스트 책', result.title);
    System.assertEquals('3권', result.volume);
    System.assert(result.price.endsWith('원'));
  }
}
