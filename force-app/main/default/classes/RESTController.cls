public with sharing class RESTController {

    // 먼짓을 해도 Flow에서 sync로 callout 안됨

    @InvocableMethod(Callout=true Label='rest test' Description = '테스트용이에용')
    public static List<returnVariables> getLatestBook(){

        IF_Util ifu = new IF_Util();
        String url = ifu.proxyConUrl('library/bookbyvolumes/latest');

        List<BookByVolume__x> listBook = new List<BookByVolume__x>();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('GET');
        HttpResponse response = http.send(request);

        // todo IsPurchased__c = FALSE AND NoNeedToBuy__c = FALSE 인것만 가져오기

        List<returnVariables> re = new List<returnVariables>();
        returnVariables objRe;

        if(response.getStatusCode() == 200) {

            List<BookDTO.BookByVolume> listBBV = (List<BookDTO.BookByVolume>) JSON.deserialize(response.getBody(), List<BookDTO.BookByVolume>.class);
            BookByVolume__x objBook;

            for(BookDTO.BookByVolume obj : listBBV){
                objBook = new BookByVolume__x();
                objBook.Seq__c = obj.seq;
                objBook.Book__c = obj.book;
                objBook.Cover__c = obj.cover;
                objBook.ISBN13__c = obj.isbn13;
                objBook.Price__c = obj.price;
                objBook.IsPurchased__c = obj.isPurchased;
                objBook.Name__c = obj.name;
                objBook.Type__c = obj.type;
                objBook.Volume__c = obj.volume;
                objBook.NoNeedToBuy__c = obj.noneedToBuy;
                objBook.Id__c = obj.id;
                objBook.ISBN__c = obj.isbn;
                objBook.Description__c = obj.description;
                objBook.Link__c = obj.link;
                objBook.PubDate__c = Datetime.valueOf(obj.pubDate);
                objBook.Author__c = obj.author;
                listBook.add(objBook);

                objRe = new returnVariables();
                objRe.returnName = obj.name;
                re.add(objRe);
            }
        }

        return re;
    }

    public class returnVariables{
        @InvocableVariable
        public String returnName;
    }


}