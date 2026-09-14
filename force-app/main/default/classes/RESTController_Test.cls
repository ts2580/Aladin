@IsTest
private class RESTController_Test {
  private class LatestBookMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setStatusCode(200);
      response.setBody('[]');
      return response;
    }
  }

  @IsTest
  static void returnsEmptyFlowResultForEmptyApiResponse() {
    Test.setMock(HttpCalloutMock.class, new LatestBookMock());
    System.assertEquals(0, RESTController.getLatestBook().size());
  }
}
