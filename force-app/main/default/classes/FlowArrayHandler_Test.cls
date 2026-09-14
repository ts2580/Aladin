@IsTest
private class FlowArrayHandler_Test {
  @IsTest
  static void savesFlowArraysAsJson() {
    TestTempSave__c parent = new TestTempSave__c();
    insert parent;

    FlowArrayHandler.InputWrapper input = new FlowArrayHandler.InputWrapper();
    input.objTempId = parent.Id;
    input.arrayTemp2 = new List<TestTempSave2__c>();
    input.arrayTemp3 = new List<TestTempSave3__c>();
    input.arrayTemp4 = new List<TestTempSave4__c>();
    input.arrayIds = new List<String>{ 'A', 'B' };

    FlowArrayHandler.execute(new List<FlowArrayHandler.InputWrapper>{ input });
    parent = [SELECT JSON__c FROM TestTempSave__c WHERE Id = :parent.Id];
    System.assert(parent.JSON__c.contains('arrayIds'));
  }
}
