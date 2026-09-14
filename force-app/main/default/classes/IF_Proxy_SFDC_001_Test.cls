@IsTest
private class IF_Proxy_SFDC_001_Test {
  @IsTest
  static void distributesRequestedTable() {
    RestRequest request = new RestRequest();
    request.requestURI = '/table/Contact';
    request.httpMethod = 'GET';
    RestContext.request = request;
    RestContext.response = new RestResponse();

    List<SObject> result = IF_Proxy_SFDC_001.distribute();

    System.assertEquals(0, result.size());
  }
}
