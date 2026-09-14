@IsTest
private class CryptoUtil_Test {
  private class StaticResourceCreateMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      System.assertEquals('POST', request.getMethod());
      System.assert(
        request.getEndpoint().endsWith('/tooling/sobjects/StaticResource')
      );
      System.assert(request.getHeader('Authorization').startsWith('Bearer '));

      Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(
        request.getBody()
      );
      System.assertEquals('AESKey', body.get('Name'));
      System.assertEquals('application/octet-stream', body.get('ContentType'));
      System.assertEquals('Private', body.get('CacheControl'));
      System.assertEquals(
        48,
        EncodingUtil.base64Decode((String) body.get('Body')).size()
      );

      HttpResponse response = new HttpResponse();
      response.setStatusCode(201);
      response.setBody(
        '{"id":"081000000000001AAA","success":true,"errors":[]}'
      );
      return response;
    }
  }

  private class StaticResourceCreateFailureMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setStatusCode(400);
      response.setBody(
        '[{"errorCode":"DUPLICATE_VALUE","message":"duplicate value"}]'
      );
      return response;
    }
  }

  @IsTest
  static void encryptsAndDecryptsWithConfiguredKey() {
    CryptoUtil.useStaticResourceBodyForTest = true;
    CryptoUtil.staticResourceBodyForTest = '123456789012345678901234567890123456789012345678';

    CryptoUtil crypto = new CryptoUtil();
    String encrypted = crypto.getEncrypt('테스트 문자열');

    System.assertNotEquals('테스트 문자열', encrypted);
    System.assertEquals('테스트 문자열', crypto.getDecrypt(encrypted));
  }

  @IsTest
  static void generatesKeyWhenStaticResourceIsMissing() {
    CryptoUtil.useStaticResourceBodyForTest = true;
    CryptoUtil.staticResourceBodyForTest = null;
    Test.setMock(HttpCalloutMock.class, new StaticResourceCreateMock());

    Test.startTest();
    CryptoUtil crypto = new CryptoUtil();
    String encrypted = crypto.getEncrypt('자동 생성 키');
    Test.stopTest();

    System.assertNotEquals('자동 생성 키', encrypted);
    System.assertEquals('자동 생성 키', crypto.getDecrypt(encrypted));
  }

  @IsTest
  static void failsWhenGeneratedKeyCannotBeSaved() {
    CryptoUtil.useStaticResourceBodyForTest = true;
    CryptoUtil.staticResourceBodyForTest = null;
    Test.setMock(HttpCalloutMock.class, new StaticResourceCreateFailureMock());

    try {
      new CryptoUtil();
      System.assert(false, '저장 실패 시 예외가 발생해야 합니다.');
    } catch (CryptoUtil.CryptoUtilException e) {
      System.assert(e.getMessage().contains('HTTP 400'));
    }
  }

  @IsTest
  static void handlesInvalidEncryptionInputs() {
    CryptoUtil.useStaticResourceBodyForTest = true;
    CryptoUtil.staticResourceBodyForTest = '123456789012345678901234567890123456789012345678';
    CryptoUtil crypto = new CryptoUtil();

    crypto.getEncrypt(null);
    System.assertEquals(null, crypto.getDecrypt('invalid-base64'));
  }
}
