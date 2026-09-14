/**
 * Created by 한성진 on 2022-10-28.
 */

public with sharing class IF_GetRecentBook {
  /**
   * @param page : 검색할 페이지
   * @param categoryId : comic 2551, lightNobel 50927, sf 152664
   *
   * @return BookInfo
   */
  public static BookInfo getRecentBook(Integer page, Integer categoryId) {
    IF_Util IF_Util = new IF_Util();

    String url = IF_Util.getRecentBook(page, categoryId);

    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint(url);
    request.setMethod('GET');
    HttpResponse response = http.send(request);

    BookInfo objBook = new BookInfo();
    if (response.getStatusCode() == 200) {
      objBook = (BookInfo) JSON.deserialize(response.getBody(), BookInfo.class);
    }

    return objBook;
  }

  public class BookInfo {
    @AuraEnabled
    public String version;
    @AuraEnabled
    public String logo;
    @AuraEnabled
    public String title;
    @AuraEnabled
    public String link;
    @AuraEnabled
    public String pubDate;
    @AuraEnabled
    public Integer totalResults;
    @AuraEnabled
    public Integer startIndex;
    @AuraEnabled
    public Integer itemsPerPage;
    @AuraEnabled
    public String query;
    @AuraEnabled
    public Integer searchCategoryId;
    @AuraEnabled
    public String searchCategoryName;
    @AuraEnabled
    public List<Item> item;
  }

  public class Item {
    @AuraEnabled
    public String title;
    @AuraEnabled
    public String link;
    @AuraEnabled
    public String author;
    @AuraEnabled
    public String pubDate;
    @AuraEnabled
    public String description;
    @AuraEnabled
    public String isbn;
    @AuraEnabled
    public String isbn13;
    @AuraEnabled
    public String itemId;
    @AuraEnabled
    public String priceSales;
    @AuraEnabled
    public String priceStandard;
    @AuraEnabled
    public String cover;
    @AuraEnabled
    public String categoryName;
    @AuraEnabled
    public Integer totalResults;
    @AuraEnabled
    public Integer startIndex;
    @AuraEnabled
    public Integer itemsPerPage;
    @AuraEnabled
    public String query;
    @AuraEnabled
    public Integer searchCategoryId;
    @AuraEnabled
    public String searchCategoryName;
    @AuraEnabled
    public String item;
  }
}
