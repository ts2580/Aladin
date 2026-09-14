/**
* @Author           : sungjin92@solomontech.net
* @TestClass        : FlowArrayHandler_test
* @Description      :
* @Modification Log
  Ver       Date            Author                           Modification
  ===================================================================================
  1.0       2025-12-31      sungjin92@solomontech.net           Created
*/
public with sharing class FlowArrayHandler {
  public class InputWrapper {
    @InvocableVariable(Required=true)
    public List<TestTempSave2__c> arrayTemp2;

    @InvocableVariable(Required=true)
    public List<TestTempSave3__c> arrayTemp3;

    @InvocableVariable(Required=true)
    public List<TestTempSave4__c> arrayTemp4;

    @InvocableVariable(Required=true)
    public String objTempId;

    @InvocableVariable
    public List<String> arrayIds;
  }

  // (선택) Flow로 반환할 출력 Wrapper
  public class OutputWrapper {
    @InvocableVariable
    public Integer totalCount;
  }

  @InvocableMethod
  public static void execute(List<InputWrapper> inputs) {
    String strJson = JSON.serializePretty(inputs[0]);

    System.debug(strJson);

    TestTempSave__c objTempSav = new TestTempSave__c();
    objTempSav.Id = inputs[0].objTempId;
    objTempSav.JSON__c = strJson;
    update objTempSav;
  }
}
