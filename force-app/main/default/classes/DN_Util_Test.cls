@IsTest
private class DN_Util_Test {
  @IsTest
  static void describesStandardObjectMetadata() {
    System.assertEquals(
      0,
      DN_Util.getFieldSet('Account', 'MissingFieldSet').size()
    );
    System.assertEquals(
      0,
      DN_Util.getFieldSetForAPIName('Account', 'MissingFieldSet').size()
    );
    System.assert(DN_Util.getFieldAPILabel('Account').containsKey('Name'));
    System.assert(DN_Util.getAllFieldsStr('Account').contains('Id'));
    System.assert(DN_Util.getPickListValueMap('Account', 'Type').size() > 0);
    System.assertEquals('String', DN_Util.getTypeX('값'));
    System.assertEquals('', DN_Util.getTypeX(null));
  }
}
