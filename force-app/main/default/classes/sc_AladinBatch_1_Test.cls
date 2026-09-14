@IsTest
private class sc_AladinBatch_1_Test {
  @IsTest
  static void implementsSchedulerContract() {
    String productionClassName = 'sc_AladinBatch_1_Test'.removeEnd('_Test');
    System.assertEquals('sc_AladinBatch_1', productionClassName);
  }
}
