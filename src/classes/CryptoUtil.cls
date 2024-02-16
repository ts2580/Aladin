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
    private String key = null;                          // 키
    private String iv = null;                           // 초기화 벡터

    public CryptoUtil(){

        // key와 초기화 벡터는 스태틱 리소스에 안전하고 프라이빗하게 비랍으로 보관

        StaticResource objStaticResource = [
                SELECT Id, Body
                FROM StaticResource
                WHERE Name = 'AESKey'
        ];

        String keyIv = objStaticResource.Body.toString();

        key = keyIv.substring(0,32);                    // 32바이트
        iv = keyIv.substring(32,48);                    // 16바이트
    }

    public String getEncrypt(String reqParam) {

        String strEn;

        if(String.isBlank(reqParam)){
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

            if(strEn.startsWith('sH+')) {
                strEn = 'a' + strEn;
            }
        } catch(Exception e) {
            System.debug('EncryptError >>' + e.getMessage());
        }

        return strEn;

    }

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

        } catch(Exception e) {
            System.debug('DecryptError >>' + e.getMessage());
        }

        return strDe;
    }

    public Map<String, String> getRSA(String reqParam) {

        StaticResource objStaticResource = [
                SELECT Id, Body
                FROM StaticResource
                WHERE Name = 'RSAKey'
        ];

        String key = objStaticResource.Body.toString();

        Blob privateKey = EncodingUtil.base64Decode(key);
        Blob input = Blob.valueOf(reqParam);

        Blob RSA_SHA1 = Crypto.sign('RSA-SHA1', input, privateKey);
        Blob RSA_SHA256 = Crypto.sign('RSA-SHA256', input, privateKey);
        Blob RSA_SHA384 = Crypto.sign('RSA-SHA384', input, privateKey);
        Blob RSA_SHA512 = Crypto.sign('RSA-SHA512', input, privateKey);

        Map<String, String> mapRSA = new Map<String, String>();
        mapRSA.put('RSA_SHA1', EncodingUtil.base64Encode(RSA_SHA1));
        mapRSA.put('RSA_SHA256', EncodingUtil.base64Encode(RSA_SHA256));
        mapRSA.put('RSA_SHA384', EncodingUtil.base64Encode(RSA_SHA384));
        mapRSA.put('RSA_SHA512', EncodingUtil.base64Encode(RSA_SHA512));

        return mapRSA;
    }
}