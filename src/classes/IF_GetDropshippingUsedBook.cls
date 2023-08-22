/**
 * Created by SUNGJIN on 2022-10-02.
 */


global with sharing class IF_GetDropshippingUsedBook {

    global class Output {
        public String  version;                     // API Version
        public String  title;                       // API 결과의 제목, 책 제목은 아님
        public String  link;                        // 새 책 링크
        public String  pubDate;                     // API 실행일
        public Integer totalResults;                // API의 총 결과수
        public Integer startIndex;                  // Page수
        public Integer itemsPerPage;                // 한 페이지에 출력될 상품 수
        public String  query;                       // API로 조회한 쿼리
        public Integer searchCategoryId;            // 분야로 조회한 경우 해당 분야의 ID
        public String  searchCategoryName;          // 분야로 조회한 경우 해당 분야의 분야명
        public List<Item> item;                     // 상품정보
    }
    
    global class Item {
        public String  title;                       // 상품명
        public String  link;                        // 상품 링크 URL(새책)
        public String  author;                      // 작가
        public String  pubDate;                     // 출간일
        public String  description;                 // 상품설명 (요약)
        public String  isbn;                        // 10자리 ISBN
        public String  isbn13;                      // 13자리 ISBN
        public Integer itemId;                      // 상품을 구분짓는 Key, 알라딘 내에서 사용
        public Integer priceSales;                  // 판매가
        public Integer priceStandard;               // 정가
        public String  mallType;                    // 상품의 몰타입. 국내도서:BOOK, 음반:MUSIC, Dvd:DVD, 외서:FOREIGN, 전자책:EBOOK, 중고상품:USED
        public String  stockStatus;                 // 재고상태(정상유통일 경우 비어있음, 품절/절판 등)
        public String  cover;                       // 표지
        public Integer categoryId;                  // 전체 분야 정보 - 카테고리 ID
        public String  categoryName;                // 전체 분야 정보 - 카테고리 명
        public String  publisher;                   // 출판사
        public Integer salesPoint;                  // 판매지수
        public String  adult;                       // 성인등급 여부
        public String  fixedPrice;                  // 정가제 여부
        public Integer customerReviewRank;          // 회원 리뷰 평점
        public SubInfo subInfo;                     // 회원 리뷰 평점
    }

    global class SubInfo {
        public String  subTitle;                    // 부제
        public String  originalTitle;               // 원제
        public Integer itemPage;                    // 상품의 쪽수
        public UsedList usedList;                   // 해당 상품에 등록된 중고상품 정보
    }

    global class UsedList {
        public AladinUsed aladinUsed;               // 알라딘 직배송 중고정보
        public SpaceUsed  spaceUsed;                // 광활한 우주점(매장 배송) 중고의 정보
    }

    global class AladinUsed {
        public String  link;                        // 알라딘 직접 배송 중고의 리스트 페이지 URL
        public Integer itemCount;                   // 알라딘 직접 배송 중고의 보유 상품수
        public Integer minPrice;                    // 알라딘 직접 배송 중고의 보유 상품중 최저가 상품 판매가격
    }

    global class SpaceUsed {
        public String  link;                        // 광활한 우주점(매장 배송) 중고의 리스트 페이지 URL
        public Integer itemCount;                   // 광활한 우주점(매장 배송) 중고의 보유 상품수
        public Integer minPrice;                    // 광활한 우주점(매장 배송) 중고의 보유 상품중 최저가 상품 판매가격
    }

    global static List<BranchBookExt__x> getBookListInfo(List<BookByVolume__x> listBooks, Integer StartNum, Integer ENDNum){

        InterfaceLog__c IFL = new InterfaceLog__c();
        List<BranchBookExt__x> listBranchBookExt = new List<BranchBookExt__x>();

        // Aladin Open Api단 에러 체크
        if(!listBooks.isEmpty()){
            try {
                listBranchBookExt = getStockToExt(listBooks);
            } catch (Exception e) {
                IFL.StartNum__c = StartNum;
                IFL.ENDNum__c = ENDNum;
                IFL.Name = ' Seq ' + StartNum + ' ~ ' + ENDNum +'사이 중고책 정보 삽입 실패';
                IFL.Log__c = e.getMessage();

                insert IFL;
            }
        }

        return listBranchBookExt;
    }

    public static List<BranchBookExt__x> getStockToExt(List<BookByVolume__x> listBooks){

        Output output = new Output();
        Item item = new Item();
        SubInfo subInfo = new SubInfo();
        UsedList usedList = new UsedList();
        AladinUsed aladinUsed = new AladinUsed();
        SpaceUsed spaceUsed = new SpaceUsed();

        IF_Util IFU = new IF_Util();

        List<BranchBookExt__x> ListBranchBook = new List<BranchBookExt__x>();
        List<InterfaceLog__c> listIFL = new List<InterfaceLog__c>();
        Map<String, Id> BranchMap = IFU.getBranch();
        Map<String, String> ParamMap = new Map<String, String>();

        BranchBookExt__x BranchBook;
        for(BookByVolume__x BBV : listBooks){

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(IFU.getDropshippingUsedBookURL(BBV.ISBN13__c));
            request.setMethod('GET');
            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {

                output = (Output) JSON.deserialize(response.getBody(), Output.class);

                item = output.item[0];
                subInfo = item.subInfo;
                usedList = subInfo.usedList;
                aladinUsed = usedList.aladinUsed;

                Integer IsDropShipping = aladinUsed.itemCount;
                Integer minPrice = aladinUsed.minPrice;

                if(IsDropShipping != 0 && String.isNotBlank(String.valueOf(IsDropShipping))){
                    BBV.Volume__c = (BBV.Volume__c == null) ? 1 : BBV.Volume__c;

                    BranchBook = new BranchBookExt__x();
                    BranchBook.Name__c = BBV.Name__c;
                    BranchBook.Book__c = BBV.Book__c;
                    BranchBook.Branch__c = BranchMap.get('알라딘 직배송');
                    BranchBook.BranchName__c = '알라딘 직배송';
                    BranchBook.Volume__c = BBV.Volume__c;
                    BranchBook.BookLink__c = aladinUsed.link.replace('amp;','');
                    BranchBook.MinPrice__c = String.valueOf(minPrice);
                    ListBranchBook.add(BranchBook);
                }

                spaceUsed = usedList.spaceUsed;

                Integer IsThereSpaceUsed = spaceUsed.itemCount;
                Integer spaceMinPrice = spaceUsed.minPrice;

                if(IsThereSpaceUsed != 0 && String.isNotBlank(String.valueOf(IsThereSpaceUsed))){
                    ParamMap.put('BookName', BBV.Name__c);
                    ParamMap.put('ISBN13', BBV.ISBN13__c);
                    ParamMap.put('MinPrice', String.valueOf(spaceMinPrice));
                    ParamMap.put('MasterBook', BBV.Book__c);
                    ParamMap.put('Volume', String.valueOf(BBV.Volume__c));

                    try{
                        List<BranchBookExt__x> spaceBranchBook = IF_GetUsedBookInfo.getUsedBookInfo(BranchMap, ParamMap);

                        for(BranchBookExt__x SBB : spaceBranchBook){
                            ListBranchBook.add(SBB);
                        }
                    }catch(Exception e){
                        InterfaceLog__c IFL = new InterfaceLog__c();
                        IFL.StartNum__c = BBV.Seq__c;
                        IFL.ENDNum__c = BBV.Seq__c + 1;
                        IFL.Name = '"' + BBV.Name__c + '"' + '재고 정보 가져오기 실패';
                        IFL.Log__c = e.getMessage();
                        listIFL.add(IFL);
                    }
                }
            }
        }
        insert listIFL;

        return ListBranchBook;
    }

    public static void getStock(List<BookByVolume__x> listBooks){

        Output output = new Output();
        Item item = new Item();
        SubInfo subInfo = new SubInfo();
        UsedList usedList = new UsedList();
        AladinUsed aladinUsed = new AladinUsed();
        SpaceUsed spaceUsed = new SpaceUsed();


        IF_Util IFU = new IF_Util();

        List<BranchBook__c> ListBranchBook = new List<BranchBook__c>();
        List<InterfaceLog__c> listIFL = new List<InterfaceLog__c>();
        Map<String, Id> BranchMap = IFU.getBranch();
        Map<String, String> ParamMap = new Map<String, String>();

        for(BookByVolume__x BBV : listBooks){

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(IFU.getDropshippingUsedBookURL(BBV.ISBN13__c));
            request.setMethod('GET');
            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {

                output = (Output) JSON.deserialize(response.getBody(), Output.class);

                item = output.item[0];
                subInfo = item.subInfo;
                usedList = subInfo.usedList;
                aladinUsed = usedList.aladinUsed;

                Integer IsDropShipping = aladinUsed.itemCount;
                Integer minPrice = aladinUsed.minPrice;

                if(IsDropShipping != 0 && String.isNotBlank(String.valueOf(IsDropShipping))){
                    BBV.Volume__c = (BBV.Volume__c == null) ? 1 : BBV.Volume__c;

                    BranchBook__c BranchBook = new BranchBook__c();
                    BranchBook.Name = BBV.Name__c;
                    BranchBook.Branch__c = BranchMap.get('알라딘 직배송');
                    BranchBook.BranchName__c = '알라딘 직배송';
                    BranchBook.Book__c = BBV.Book__c;
                    BranchBook.Volume__c = BBV.Volume__c;
                    BranchBook.BookLink__c = aladinUsed.link.replace('amp;','');
                    BranchBook.MinPrice__c = String.valueOf(minPrice);
                    ListBranchBook.add(BranchBook);
                }

                spaceUsed = usedList.spaceUsed;

                Integer IsThereSpaceUsed = spaceUsed.itemCount;
                Integer spaceMinPrice = spaceUsed.minPrice;

                if(IsThereSpaceUsed != 0 && String.isNotBlank(String.valueOf(IsThereSpaceUsed))){
                    ParamMap.put('BookName', BBV.Name__c);
                    ParamMap.put('ISBN13', BBV.ISBN13__c);
                    ParamMap.put('MinPrice', String.valueOf(spaceMinPrice));
                    ParamMap.put('MasterBook', BBV.Book__c);
                    ParamMap.put('Volume', String.valueOf(BBV.Volume__c));

                    try{
                        List<BranchBook__c> spaceBranchBook = IF_GetUsedBookInfo.getUsedBookInfoBU(BranchMap, ParamMap);

                        for(BranchBook__c SBB : spaceBranchBook){
                            ListBranchBook.add(SBB);
                        }
                    }catch(Exception e){
                        InterfaceLog__c IFL = new InterfaceLog__c();
                        IFL.StartNum__c = BBV.Seq__c;
                        IFL.ENDNum__c = BBV.Seq__c + 1;
                        IFL.Name = '"' + BBV.Name__c + '"' + '재고 정보 가져오기 실패';
                        IFL.Log__c = e.getMessage();
                        listIFL.add(IFL);
                    }
                }
            }
        }

        System.debug(JSON.serialize(ListBranchBook));
    }

    @Future(Callout=true)
    public static void getStockAsync(String strBookX){

        // json 받아서 파씽하고 비동기로 바꾸기
        List<BookByVolume__x> listBooks = (List<BookByVolume__x>) JSON.deserialize(strBookX, List<BookByVolume__x>.class);

        Output output = new Output();
        Item item = new Item();
        SubInfo subInfo = new SubInfo();
        UsedList usedList = new UsedList();
        AladinUsed aladinUsed = new AladinUsed();
        SpaceUsed spaceUsed = new SpaceUsed();

        IF_Util IFU = new IF_Util();

        List<BranchBook__c> ListBranchBook = new List<BranchBook__c>();
        List<InterfaceLog__c> listIFL = new List<InterfaceLog__c>();
        Map<String, Id> BranchMap = IFU.getBranch();
        Map<String, String> ParamMap = new Map<String, String>();

        for(BookByVolume__x BBV : listBooks){

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(IFU.getDropshippingUsedBookURL(BBV.ISBN13__c));
            request.setMethod('GET');
            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {

                output = (Output) JSON.deserialize(response.getBody(), Output.class);

                item = output.item[0];
                subInfo = item.subInfo;
                usedList = subInfo.usedList;
                aladinUsed = usedList.aladinUsed;

                Integer IsDropShipping = aladinUsed.itemCount;
                Integer minPrice = aladinUsed.minPrice;

                if(IsDropShipping != 0 && String.isNotBlank(String.valueOf(IsDropShipping))){
                    BBV.Volume__c = (BBV.Volume__c == null) ? 1 : BBV.Volume__c;

                    BranchBook__c BranchBook = new BranchBook__c();
                    BranchBook.Name = BBV.Name__c;
                    BranchBook.Branch__c = BranchMap.get('알라딘 직배송');
                    BranchBook.BranchName__c = '알라딘 직배송';
                    BranchBook.Book__c = BBV.Book__c;
                    BranchBook.Volume__c = BBV.Volume__c;
                    BranchBook.BookLink__c = aladinUsed.link.replace('amp;','');
                    BranchBook.MinPrice__c = String.valueOf(minPrice);
                    ListBranchBook.add(BranchBook);
                }

                spaceUsed = usedList.spaceUsed;

                Integer IsThereSpaceUsed = spaceUsed.itemCount;
                Integer spaceMinPrice = spaceUsed.minPrice;

                if(IsThereSpaceUsed != 0 && String.isNotBlank(String.valueOf(IsThereSpaceUsed))){
                    ParamMap.put('BookName', BBV.Name__c);
                    ParamMap.put('ISBN13', BBV.ISBN13__c);
                    ParamMap.put('MinPrice', String.valueOf(spaceMinPrice));
                    ParamMap.put('MasterBook', BBV.Book__c);
                    ParamMap.put('Volume', String.valueOf(BBV.Volume__c));

                    try{
                        List<BranchBook__c> spaceBranchBook = IF_GetUsedBookInfo.getUsedBookInfoBU(BranchMap, ParamMap);

                        for(BranchBook__c SBB : spaceBranchBook){
                            ListBranchBook.add(SBB);
                        }
                    }catch(Exception e){
                        InterfaceLog__c IFL = new InterfaceLog__c();
                        IFL.StartNum__c = BBV.Seq__c;
                        IFL.ENDNum__c = BBV.Seq__c + 1;
                        IFL.Name = '"' + BBV.Name__c + '"' + '재고 정보 가져오기 실패';
                        IFL.Log__c = e.getMessage();
                        listIFL.add(IFL);
                    }
                }
            }
        }

        insert ListBranchBook;
        insert listIFL;
    }


    public static void Run(Integer StartNum){

        Integer endNum = StartNum + 50;

        List<BookByVolume__x> listBooks = [
                SELECT Id, ISBN13__c, ISBN__c, Id__c, Link__c, PubDate__c, Author__c
                FROM BookByVolume__x
                WHERE Id__c >=: StartNum
                AND Id__c <: endNum
        ];

    }

    public static void getInfo(List<BookByVolume__x> listBooks){

        Output output = new Output();
        Item item = new Item();
        IF_Util IFU = new IF_Util();

        if(listBooks.size() > 0){
            for(BookByVolume__x BBV : listBooks){

                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(IFU.getDropshippingUsedBookURL(BBV.ISBN13__c));
                request.setMethod('GET');
                request.setTimeout(20000);
                HttpResponse response = http.send(request);

                if (response.getStatusCode() == 200) {

                    output = (Output) JSON.deserialize(response.getBody(), Output.class);

                    item = output.item[0];
                    BBV.Description__c = item.description.abbreviate(1000);             // 설명
                    BBV.Link__c = item.link;                                            // 새 책 구매 링크
                    BBV.PubDate__c = Date.valueOf(item.pubDate);                        // 출간일
                    BBV.Author__c = item.author;                                        // 작가
                }
            }
            Database.updateAsync(listBooks);
        }
    }
}