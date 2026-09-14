@IsTest
private class ToolingController_Test {
  private class ToolingMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setStatusCode(200);
      if (request.getEndpoint().endsWith('/services/data')) {
        response.setBody(
          '[{"label":"Spring 26","url":"/services/data/v64.0","version":"64.0"}]'
        );
      } else {
        response.setBody('{"sobjects":[]}');
      }
      return response;
    }
  }

  @IsTest
  static void returnsObjectDefinitions() {
    Test.setMock(HttpCalloutMock.class, new ToolingMock());
    RestRequest request = new RestRequest();
    request.requestURI = '/tooling/objDef';
    request.httpMethod = 'GET';
    RestContext.request = request;
    RestContext.response = new RestResponse();

    System.assertNotEquals(null, ToolingController.distribute());
  }
}
