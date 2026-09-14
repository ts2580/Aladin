@IsTest
private class S4_Util_Test {
  private class ToolingMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setStatusCode(201);
      response.setBody('{"success":true,"id":"00N000000000001"}');
      return response;
    }
  }

  @IsTest
  static void describesFieldsAndBuildsToolingRequest() {
    System.assert(S4_Util.getAllFieldsStr('Account').contains('Id'));
    Test.setMock(HttpCalloutMock.class, new ToolingMock());
    String result = S4_Util.setCustomTextField(
      'Account',
      '테스트',
      'CodexTest',
      '테스트 필드',
      20,
      null,
      false
    );
    System.assert(result.contains('success'));
  }
}
