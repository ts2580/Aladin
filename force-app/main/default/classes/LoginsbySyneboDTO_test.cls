@IsTest
private class LoginsbySyneboDTO_Test {
  @IsTest
  static void deserializesExportedCredentials() {
    String payload =
      '{"groups":[{"Name":"개발","credentials":[' +
      '{"Name":"Aladin","SfName":"user@example.com","Password":"secret",' +
      '"Type":{"Id":"Production"}}]}]}';

    LoginsbySyneboDTO result = LoginsbySyneboDTO.getSynebo(payload);

    System.assertEquals('개발', result.groups[0].Name);
    System.assertEquals(
      'user@example.com',
      result.groups[0].credentials[0].SfName
    );
    System.assertEquals('Production', result.groups[0].credentials[0].Type.Id);
  }
}
