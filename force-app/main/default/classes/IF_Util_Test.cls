@IsTest
private class IF_Util_Test {
  private class IpMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setStatusCode(200);
      response.setBody('127.0.0.1');
      return response;
    }
  }

  @IsTest
  static void buildsEndpointsAndReadsIp() {
    IF_Util util = new IF_Util();
    System.assert(util.getBookInfoURL('테스트 책').contains('ItemSearch.aspx'));
    System.assert(
      util.getDropshippingUsedBookURL('123').contains('ItemLookUp.aspx')
    );
    System.assert(
      util.getUsedBookInfoURL('123').contains('ItemOffStoreList.aspx')
    );
    System.assert(util.getRecentBook(1, 2551).contains('ItemList.aspx'));
    System.assertEquals(
      'https://book.sfdevhub.com/path',
      util.proxyConUrl('path')
    );
    System.assertEquals(0, util.getBranch().size());

    Test.setMock(HttpCalloutMock.class, new IpMock());
    System.assertEquals('127.0.0.1', util.getMyIp());
  }
}
