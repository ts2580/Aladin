/**
 * Created by HSJ on 24. 11. 2..
 */

@IsTest
public with sharing class LoginsbySyneboDTO_test {

    @IsTest
    static void testGetSynebo() {

        LoginsbySyneboDTO.Groups groupDTO = new LoginsbySyneboDTO.Groups();
        LoginsbySyneboDTO.Credential credential = new LoginsbySyneboDTO.Credential();
        LoginsbySyneboDTO.Type type = new LoginsbySyneboDTO.Type();
        type.Id = 'trstyq';
        credential.Name = '성진';
        credential.Password = '성진';
        credential.SfName = '성진';
        credential.Type = type;

        groupDTO.credentials = new List<LoginsbySyneboDTO.Credential>{credential};


        // JSON 문자열을 객체로 파싱
        LoginsbySyneboDTO.getSynebo(JSON.serializePretty(groupDTO));


    }



}