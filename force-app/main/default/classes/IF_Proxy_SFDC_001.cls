/**
 * Created by 한성진 on 2022-10-28.
 */

@RestResource(UrlMapping='/table/*')
global with sharing class IF_Proxy_SFDC_001 {

    @HttpGet
    global static List<SObject> distribute(){

        List<SObject> lSOB = new List<SObject>();

        // /table/Book__c
        String uri = RestContext.request.requestURI;

        String apiName = uri.split('/')[2];

        System.debug('uri : ' + uri);
        System.debug('apiName : ' + apiName);

        String sizeQuery = 'select count(id) from ' + apiName;

        AggregateResult agR = Database.query(sizeQuery);

        Integer size = Integer.valueOf(agR.get('expr0'));

        if(size < 10000){
            lSOB = getData(apiName);
        }else{
            lSOB = getDataBulk(apiName);
        }

        return lSOB;
    }

    private static List<SObject> getData(String apiName) {

        Util util = new Util();

        String fields = util.getAllFieldsStr(apiName);

        String query = 'SELECT ' + fields + ' FROM ' + apiName;

        List<SObject> listSobj = Database.query(query);

        return listSobj;
    }

    private static List<SObject> getDataBulk(String apiName) {

        // todo Bulk API 2.0으로 작동하는것 만들기

        return null;
    }

}