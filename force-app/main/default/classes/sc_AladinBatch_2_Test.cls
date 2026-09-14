@IsTest
private class sc_AladinBatch_2_Test {
  @IsTest
  static void marksFailedLogsForRerun() {
    InterfaceLog__c log = new InterfaceLog__c(
      Name = '실패 로그',
      StartNum__c = 1,
      ENDNum__c = 2,
      IsRerun__c = false
    );
    insert log;

    new sc_AladinBatch_2().execute(null);

    log = [SELECT IsRerun__c FROM InterfaceLog__c WHERE Id = :log.Id];
    System.assertEquals(true, log.IsRerun__c);
  }
}
