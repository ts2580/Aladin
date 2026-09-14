@IsTest
private class IF_InsertLatestBook_Test {
  private class BookInfoMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setStatusCode(200);
      response.setBody(
        '{"item":[{' +
          '"title":"테스트 책","isbn13":"9780000000000","priceSales":12000,' +
          '"cover":"https://example.com/cover200/test.jpg","description":"설명",' +
          '"link":"https://example.com/book","pubDate":"2026-01-01","author":"작가"' +
          '}]}'
      );
      return response;
    }
  }

  @IsTest
  static void mapsLatestBookResponse() {
    Test.setMock(HttpCalloutMock.class, new BookInfoMock());
    BookByVolume__x source = new BookByVolume__x(
      Name__c = '테스트 책',
      Id__c = 1,
      Type__c = '소설',
      Volume__c = 1,
      IsPurchased__c = false,
      NoNeedToBuy__c = false
    );

    BookDTO.BookByVolume result = IF_InsertLatestBook.insertLatestBook(source);

    System.assertEquals('테스트 책', result.name);
    System.assertEquals('12000', result.price);
    System.assert(result.cover.contains('cover500'));
  }
}
