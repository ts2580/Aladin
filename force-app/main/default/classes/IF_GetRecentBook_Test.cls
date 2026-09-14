@IsTest
private class IF_GetRecentBook_Test {
  private class RecentBookMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setStatusCode(200);
      response.setBody('{"title":"신간","totalResults":1,"item":[]}');
      return response;
    }
  }

  @IsTest
  static void parsesRecentBooks() {
    Test.setMock(HttpCalloutMock.class, new RecentBookMock());
    IF_GetRecentBook.BookInfo result = IF_GetRecentBook.getRecentBook(1, 2551);

    System.assertEquals('신간', result.title);
    System.assertEquals(1, result.totalResults);
    System.assertEquals(0, result.item.size());
  }
}
