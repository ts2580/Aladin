@IsTest
private class IF_GetDropshippingUsedBook_Test {
  @IsTest
  static void representsDropshippingPayload() {
    IF_GetDropshippingUsedBook.AladinUsed aladin = new IF_GetDropshippingUsedBook.AladinUsed();
    aladin.itemCount = 2;
    aladin.minPrice = 3000;
    IF_GetDropshippingUsedBook.UsedList used = new IF_GetDropshippingUsedBook.UsedList();
    used.aladinUsed = aladin;
    IF_GetDropshippingUsedBook.SubInfo subInfo = new IF_GetDropshippingUsedBook.SubInfo();
    subInfo.usedList = used;
    IF_GetDropshippingUsedBook.Item item = new IF_GetDropshippingUsedBook.Item();
    item.title = '테스트 책';
    item.subInfo = subInfo;
    IF_GetDropshippingUsedBook.Output output = new IF_GetDropshippingUsedBook.Output();
    output.item = new List<IF_GetDropshippingUsedBook.Item>{ item };

    String payload = JSON.serialize(output);
    System.assert(payload.contains('테스트 책'));
    System.assert(payload.contains('3000'));
  }
}
