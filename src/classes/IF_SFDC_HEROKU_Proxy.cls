/**
 * Created by 한성진 on 2022-10-28.
 */

public with sharing class IF_SFDC_HEROKU_Proxy {

    public static Object proxyConTest(String title){

        IF_Util IF_Util = new IF_Util();
        String url = IF_Util.proxyConTest(title);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('POST');
        HttpResponse response = http.send(request);

        return response.getBody();

    }

}