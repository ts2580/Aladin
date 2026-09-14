@IsTest
private class SalesforceCredentialDTO_Test {
  @IsTest
  static void convertsSyneboCredentials() {
    String payload =
      '{"groups":[{"Name":"개발","credentials":[' +
      '{"Name":"Aladin","SfName":"user@example.com","Password":"secret",' +
      '"Type":{"Id":"Production"}}]}]}';

    String converted = SalesforceCredentialDTO.transSyneboToCredential(payload);

    System.assert(converted.contains('"group"'));
    System.assert(converted.contains('"environmentType" : "login"'));
    List<SalesforceCredentialDTO.Credential> credentials = SalesforceCredentialDTO.getCredentials(
      '[{"name":"Aladin","username":"user@example.com"}]'
    );
    System.assertEquals('Aladin', credentials[0].name);
  }
}
