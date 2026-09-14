@IsTest
private class AladinHomePageComponentController_Test {
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
  static void handlesEmptyDataAndBookApiResponses() {
    Test.setMock(HttpCalloutMock.class, new BookApiMock());

    System.assertEquals(
      0,
      AladinHomePageComponentController.getBranch().size()
    );
    System.assertEquals(
      0,
      AladinHomePageComponentController.getBooKAll().size()
    );
    AladinHomePageComponentController.refreshBook(
      0,
      new List<BookByVolume__x>()
    );
    AladinHomePageComponentController.delBook();
    AladinHomePageComponentController.refreshPrice();
    AladinHomePageComponentController.rerunFailedIF();
    AladinHomePageComponentController.deleteIfLog();
  }
}
