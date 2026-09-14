@IsTest
private class CM_ExcelExportController_Test {
  @IsTest
  static void convertsEmptySheetAndFindsListViews() {
    CM_ExcelExportController controller = new CM_ExcelExportController();
    System.assertNotEquals(null, controller);
    System.assertEquals(
      0,
      CM_ExcelExportController.getExportDataFromIBSheet(
          new List<Object>(),
          'Account'
        )
        .size()
    );
    System.assertNotEquals(
      null,
      CM_ExcelExportController.getOrgListviewId('Account')
    );
  }
}
