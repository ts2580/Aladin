@IsTest
private class SearchAndInsertBookController_Test {
  private class BookApiMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setStatusCode(200);
      response.setBody(
        request.getMethod() == 'GET' ? '[]' : '{"success":true}'
      );
      return response;
    }
  }

  @IsTest
  static void handlesEmptyBookApiResults() {
    Test.setMock(HttpCalloutMock.class, new BookApiMock());

    System.assertEquals(
      0,
      SearchAndInsertBookController.getBookExt('없는 책').size()
    );
    System.assertEquals(
      0,
      SearchAndInsertBookController.getLatestBook().size()
    );
    SearchAndInsertBookController.deleteBookExt(1);
  }
}
