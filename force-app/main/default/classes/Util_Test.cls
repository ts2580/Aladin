@IsTest
private class Util_Test {
  private class IpMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setStatusCode(200);
      response.setBody('127.0.0.1');
      return response;
    }
  }

  @IsTest
  static void describesFieldsAndCallsIpService() {
    String fields = new Util().getAllFieldsStr('Account');
    System.assert(fields.contains('Id'));

    Test.setMock(HttpCalloutMock.class, new IpMock());
    Util.getIp();
  }
}
