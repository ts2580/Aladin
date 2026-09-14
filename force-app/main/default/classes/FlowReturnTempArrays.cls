/**
* @Author           : sungjin92@solomontech.net
* @TestClass        : FlowReturnTempArrays_test
* @Description      :
* @Modification Log
  Ver       Date            Author                           Modification
  ===================================================================================
  1.0       2025-12-31      sungjin92@solomontech.net           Created
*/
public with sharing class FlowReturnTempArrays {
  public class InputWrapper {
    @InvocableVariable(Required=true)
    public TestTempSave__c objTemp;
  }

  public class OutputWrapper {
    @InvocableVariable
    public List<TestTempSave2__c> arrayTemp2;

    @InvocableVariable
    public List<TestTempSave3__c> arrayTemp3;

    @InvocableVariable
    public List<TestTempSave4__c> arrayTemp4;

    @InvocableVariable
    public List<String> arrayIds;
  }

  @InvocableMethod
  public static List<OutputWrapper> execute(List<InputWrapper> inputs) {
    TestTempSave__c objTempSav = inputs[0].objTemp;

    if (String.isEmpty(objTempSav.JSON__c))
      return null;

    Map<String, Object> mapJSON = (Map<String, Object>) JSON.deserializeUntyped(
      objTempSav.JSON__c
    );

    System.debug(JSON.serializePretty(mapJSON));

    List<Object> objListTemp2 = (List<Object>) mapJSON.get('arrayTemp2');
    List<Object> objListTemp3 = (List<Object>) mapJSON.get('arrayTemp3');
    List<Object> objListTemp4 = (List<Object>) mapJSON.get('arrayTemp4');
    List<Object> objListIds = (List<Object>) mapJSON.get('arrayIds');

    List<TestTempSave2__c> arrayTemp2 = new List<TestTempSave2__c>();
    List<TestTempSave3__c> arrayTemp3 = new List<TestTempSave3__c>();
    List<TestTempSave4__c> arrayTemp4 = new List<TestTempSave4__c>();
    List<String> arrayIds = new List<String>();

    Map<String, Object> mapJSON2;
    if (objListTemp2.size() > 0) {
      TestTempSave2__c objTemp2;
      for (Object obj : objListTemp2) {
        mapJSON2 = (Map<String, Object>) obj;

        objTemp2 = new TestTempSave2__c();
        objTemp2.Name = String.valueOf(mapJSON2.get('Name'));
        objTemp2.Describe__c = String.valueOf(mapJSON2.get('Describe__c'));
        objTemp2.TestTempSave__c = objTempSav.Id;
        arrayTemp2.add(objTemp2);
      }
    }

    if (objListTemp3.size() > 0) {
      TestTempSave3__c objTemp3;
      for (Object obj : objListTemp3) {
        mapJSON2 = (Map<String, Object>) obj;

        objTemp3 = new TestTempSave3__c();
        objTemp3.Name = String.valueOf(mapJSON2.get('Name'));
        objTemp3.Describe__c = String.valueOf(mapJSON2.get('Describe__c'));
        objTemp3.TestTempSave__c = objTempSav.Id;
        arrayTemp3.add(objTemp3);
      }
    }

    if (objListTemp4.size() > 0) {
      TestTempSave4__c objTemp4;
      for (Object obj : objListTemp4) {
        mapJSON2 = (Map<String, Object>) obj;

        objTemp4 = new TestTempSave4__c();
        objTemp4.Name = String.valueOf(mapJSON2.get('Name'));
        objTemp4.Grade__c = String.valueOf(mapJSON2.get('Grade__c'));
        objTemp4.TestTempSave__c = objTempSav.Id;
        arrayTemp4.add(objTemp4);
      }
    }

    if (objListIds.size() > 0) {
      for (Object obj : objListIds) {
        arrayIds.add(String.valueOf(obj));
      }
    }

    OutputWrapper objOutputWrapper = new OutputWrapper();
    objOutputWrapper.arrayTemp2 = arrayTemp2;
    objOutputWrapper.arrayTemp3 = arrayTemp3;
    objOutputWrapper.arrayTemp4 = arrayTemp4;
    objOutputWrapper.arrayIds = arrayIds;

    System.debug(JSON.serializePretty(objOutputWrapper));

    return new List<OutputWrapper>{ objOutputWrapper };
  }
}
