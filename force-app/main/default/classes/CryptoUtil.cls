/************************************************************************************
 * File Name   		: CryptoUtil.class
 * Author	  		: 한성진
 * Date				: 2023-06-29
 * Tester	  		:
 * Description 		: I/F에 사용 할 암호화 Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2023-06-29      한성진            생성
*************************************************************************************/

public with sharing class CryptoUtil {
  private static final String AES_KEY_RESOURCE_NAME = 'AESKey';
  private static final String STATIC_RESOURCE_CONTENT_TYPE = 'application/octet-stream';
  private static final String TOOLING_API_VERSION = 'v64.0';

  @TestVisible
  private static Boolean useStaticResourceBodyForTest = false;

  @TestVisible
  private static String staticResourceBodyForTest;

  private String key = null; // 키
  private String iv = null; // 초기화 벡터

  public class CryptoUtilException extends Exception {
  }

  /**
   * AES 키와 초기화 벡터를 Static Resource에서 불러옵니다.
   * 리소스가 없으면 새 값을 생성하여 저장한 뒤 암호화에 사용할 값을 초기화합니다.
   *
   * @throws CryptoUtilException 생성한 키를 Static Resource에 저장하지 못한 경우
   */
  public CryptoUtil() {
    // todo custom setting이 나은지 확인 후 조치.

    String keyIv;
    if (useStaticResourceBodyForTest) {
      keyIv = staticResourceBodyForTest;
    } else {
      List<StaticResource> staticResources = [
        SELECT Id, Body
        FROM StaticResource
        WHERE Name = :AES_KEY_RESOURCE_NAME
        LIMIT 1
      ];

      if (!staticResources.isEmpty()) {
        keyIv = staticResources[0].Body.toString();
      }
    }

    if (keyIv == null) {
      keyIv = generateKey();
      saveStaticResource(keyIv);
    }

    key = keyIv.substring(0, 32); // 32바이트
    iv = keyIv.substring(32, 48); // 16바이트
  }

  /**
   * AES-256 키와 16바이트 초기화 벡터를 생성하여 하나의 문자열로 반환합니다.
   *
   * @return 32바이트 키와 16바이트 초기화 벡터를 이어 붙인 문자열
   */
  private String generateKey() {
    String generatedKey = EncodingUtil.base64Encode(Crypto.generateAesKey(256))
      .substring(0, 32);
    String generatedIv = EncodingUtil.base64Encode(Crypto.generateAesKey(128))
      .substring(0, 16);
    return generatedKey + generatedIv;
  }

  /**
   * 생성한 AES 키와 초기화 벡터를 비공개 Static Resource로 저장합니다.
   *
   * @param keyIv 저장할 32바이트 키와 16바이트 초기화 벡터의 결합 문자열
   * @throws CryptoUtilException Tooling API가 리소스 생성에 실패한 경우
   */
  private void saveStaticResource(String keyIv) {
    HttpRequest request = new HttpRequest();
    request.setEndpoint(
      Url.getOrgDomainUrl().toExternalForm() +
        '/services/data/' +
        TOOLING_API_VERSION +
        '/tooling/sobjects/StaticResource'
    );
    request.setMethod('POST');
    request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
    request.setHeader('Content-Type', 'application/json');
    request.setBody(
      JSON.serialize(
        new Map<String, Object>{
          'Name' => AES_KEY_RESOURCE_NAME,
          'ContentType' => STATIC_RESOURCE_CONTENT_TYPE,
          'CacheControl' => 'Private',
          'Body' => EncodingUtil.base64Encode(Blob.valueOf(keyIv))
        }
      )
    );

    HttpResponse response = new Http().send(request);
    Map<String, Object> result;
    if (!String.isBlank(response.getBody())) {
      try {
        result = (Map<String, Object>) JSON.deserializeUntyped(
          response.getBody()
        );
      } catch (Exception ignored) {
        result = null;
      }
    }

    if (
      response.getStatusCode() != 201 ||
      result == null ||
      result.get('success') != true
    ) {
      throw new CryptoUtilException(
        'AESKey Static Resource 생성에 실패했습니다. HTTP ' +
        response.getStatusCode()
      );
    }
  }

  /**
   * 전달받은 문자열을 AES-256으로 암호화하고 Base64 문자열로 반환합니다.
   *
   * @param reqParam 암호화할 평문
   * @return Base64로 인코딩한 암호문. 암호화에 실패하면 null 또는 빈 문자열
   */
  public String getEncrypt(String reqParam) {
    String strEn;

    if (String.isBlank(reqParam)) {
      strEn = '';
    }

    try {
      // Blob Type 변환
      Blob bKey = Blob.valueOf(key);
      Blob bIv = Blob.valueOf(iv);
      Blob bData = Blob.valueOf(reqParam);

      // AES256 방식 암호화
      Blob bEncryptedData = Crypto.encrypt('AES256', bKey, bIv, bData);

      // BASE64, UTF-8 인코딩
      strEn = EncodingUtil.base64Encode(bEncryptedData);

      if (strEn.startsWith('sH+')) {
        strEn = 'a' + strEn;
      }
    } catch (Exception e) {
      System.debug('EncryptError >>' + e.getMessage());
    }

    return strEn;
  }

  /**
   * Base64로 인코딩된 AES-256 암호문을 복호화합니다.
   *
   * @param reqParam 복호화할 Base64 암호문
   * @return 복호화한 평문. 복호화에 실패하면 null
   */
  public String getDecrypt(String reqParam) {
    // Return
    String strDe;

    try {
      // Blob Type 변환
      Blob bKey = Blob.valueOf(key);
      Blob bIv = Blob.valueOf(iv);
      Blob bDecryptData = EncodingUtil.base64Decode(reqParam);

      // AES256 방식 복호화
      Blob bDecryptedData = Crypto.decrypt('AES256', bKey, bIv, bDecryptData);
      strDe = bDecryptedData.toString();
    } catch (Exception e) {
      System.debug('DecryptError >>' + e.getMessage());
    }

    return strDe;
  }
}
