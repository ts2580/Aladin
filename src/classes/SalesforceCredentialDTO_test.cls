/**
 * Created by HSJ on 24. 11. 2..
 */

@IsTest
public with sharing class SalesforceCredentialDTO_test {

    @IsTest
    static void testSalesforceCredentialDTO() {


        LoginsbySyneboDTO.Groups groupDTO = new LoginsbySyneboDTO.Groups();
        LoginsbySyneboDTO.Credential credential = new LoginsbySyneboDTO.Credential();
        LoginsbySyneboDTO.Type type = new LoginsbySyneboDTO.Type();
        type.Id = 'trstyq';
        credential.Name = '성진';
        credential.Password = '성진';
        credential.SfName = '성진';
        credential.Type = type;

        groupDTO.credentials = new List<LoginsbySyneboDTO.Credential>{credential};


        List<LoginsbySyneboDTO.Groups> listGroupDTO = new List<LoginsbySyneboDTO.Groups>{groupDTO};

        LoginsbySyneboDTO dto = new LoginsbySyneboDTO();
        dto.groups = listGroupDTO;

        String syneboCredentials = JSON.serializePretty(dto);

        SalesforceCredentialDTO.transSyneboToCredential(syneboCredentials);


    }
}