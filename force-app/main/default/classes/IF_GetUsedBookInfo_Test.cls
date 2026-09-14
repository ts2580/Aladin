@IsTest
private class IF_GetUsedBookInfo_Test {
  private class UsedBookMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setStatusCode(200);
      response.setBody('{"itemOffStoreList":[]}');
      return response;
    }
  }

  @IsTest
  static void handlesNoUsedBookStock() {
    Test.setMock(HttpCalloutMock.class, new UsedBookMock());
    Map<String, String> params = new Map<String, String>{
      'ISBN13' => '9780000000000',
      'BookName' => '테스트',
      'MasterBook' => null,
      'Volume' => '1',
      'MinPrice' => '1000'
    };

    System.assertEquals(
      0,
      IF_GetUsedBookInfo.getUsedBookInfo(new Map<String, Id>(), params).size()
    );
    System.assertEquals(
      0,
      IF_GetUsedBookInfo.getUsedBookInfoBU(new Map<String, Id>(), params).size()
    );
  }
}
