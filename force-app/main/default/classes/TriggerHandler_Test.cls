@IsTest
private class TriggerHandler_Test {
  private class RecordingHandler extends TriggerHandler {
    Boolean beforeInsertCalled = false;
    protected override void beforeInsert() {
      beforeInsertCalled = true;
    }
  }

  @IsTest
  static void dispatchesAndSupportsBypass() {
    RecordingHandler handler = new RecordingHandler();
    handler.setTriggerContext('before insert', true);
    handler.run();
    System.assertEquals(true, handler.beforeInsertCalled);

    TriggerHandler.bypass('RecordingHandler');
    System.assertEquals(true, TriggerHandler.isBypassed('RecordingHandler'));
    TriggerHandler.clearAllBypasses();
    System.assertEquals(false, TriggerHandler.isBypassed('RecordingHandler'));
  }
}
