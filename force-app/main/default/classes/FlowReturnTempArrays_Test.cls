@IsTest
private class FlowReturnTempArrays_Test {
  @IsTest
  static void restoresFlowArraysFromJson() {
    TestTempSave__c parent = new TestTempSave__c();
    insert parent;
    parent.JSON__c = JSON.serialize(
      new Map<String, Object>{
        'arrayTemp2' => new List<Object>{
          new Map<String, Object>{ 'Name' => '둘', 'Describe__c' => '설명' }
        },
        'arrayTemp3' => new List<Object>{
          new Map<String, Object>{ 'Name' => '셋', 'Describe__c' => '설명' }
        },
        'arrayTemp4' => new List<Object>{
          new Map<String, Object>{ 'Name' => '넷', 'Grade__c' => 'A' }
        },
        'arrayIds' => new List<Object>{ 'A', 'B' }
      }
    );

    FlowReturnTempArrays.InputWrapper input = new FlowReturnTempArrays.InputWrapper();
    input.objTemp = parent;
    List<FlowReturnTempArrays.OutputWrapper> result = FlowReturnTempArrays.execute(
      new List<FlowReturnTempArrays.InputWrapper>{ input }
    );

    System.assertEquals(1, result[0].arrayTemp2.size());
    System.assertEquals(1, result[0].arrayTemp3.size());
    System.assertEquals(1, result[0].arrayTemp4.size());
    System.assertEquals(new List<String>{ 'A', 'B' }, result[0].arrayIds);
  }
}
