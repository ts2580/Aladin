@RestResource(UrlMapping='/tooling/*')
global with sharing class ToolingController {

    private static final String domain = Url.getOrgDomainUrl().toExternalForm();
    private static String toolingDomain;

    private class API{
        public String label;
        public String url;
        public String version;
    }

    global class ReturnParam{
        public ObjDef objDef;
        public FieldDef fieldDef;
    }

    private class ObjDef{
        public List<Sobjects> sobjects;
    }

    private class Sobjects{
        public String label;
        public String labelPlural;
        public String name;
    }

    private class FieldDef{
        public List<Records> records;
        public Integer size;
    }

    private class Records{
        public String Id;
        public String EntityDefinitionId;
        public String DeveloperName;
        public String QualifiedApiName;
        public String Label;
        public String Length;
        public String DataType;
        public String ValueTypeId;
        public String IsIndexed;
    }

    @HttpGet
    global static ReturnParam distribute(){

        String uri = RestContext.request.requestURI;

        System.debug(uri);

        ReturnParam returnParam = new ReturnParam();

        // 채신버전 API 구하기
        getLatestAPI();

        if(uri.endsWith('objDef')){
            // object 정의 구하기
            returnParam = getObjDef(returnParam);
        }else if(uri.contains('fieldDef')){
            returnParam = getFieldDef(uri.remove('/tooling/fieldDef/'), returnParam);
        }

        return returnParam;
    }

    private static ReturnParam getObjDef(ReturnParam returnParam) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + '/services/data/v60.0/sobjects');
        req.setMethod('GET');
        HttpResponse res = http.send(req);

        ObjDef objDef = (ObjDef) JSON.deserialize(res.getBody(), ObjDef.class);

        returnParam.objDef = objDef;

        return returnParam;
    }

    private static ReturnParam getFieldDef(String qApiName, ReturnParam returnParam) {
        String toolingSoql =
                'select Id, EntityDefinitionId, DeveloperName, QualifiedApiName, Label, Length, DataType, ValueTypeId, IsIndexed, EntityDefinition.QualifiedApiName ' +
                'from FieldDefinition ' +
                'where EntityDefinition.QualifiedApiName =' + '\'' +  qApiName + '\' ';
        String toolingSoqlSafe =  EncodingUtil.urlEncode(toolingSoql, 'UTF-8');

        String strEndPoint = toolingDomain + toolingSoqlSafe;

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(strEndPoint);
        req.setMethod('GET');
        HttpResponse res = http.send(req);

        FieldDef fieldDef = (FieldDef) JSON.deserialize(res.getBody(), FieldDef.class);

        returnParam.fieldDef = fieldDef;

        return returnParam;
    }

    private static void getLatestAPI() {

        String apiVersion;

        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(domain + '/services/data');
        req.setMethod('GET');

        Http http = new Http();
        HttpResponse res = http.send(req);

        List<API> listApi = (List<API>) JSON.deserialize(res.getBody(), List<API>.class);

        Decimal maxApi = 0;
        for(API obj : listApi){
            maxApi = Decimal.valueOf(obj.version) > maxApi ? Decimal.valueOf(obj.version) : maxApi;
        }

        apiVersion = 'v' +  String.valueOf(maxApi);

        toolingDomain = domain + '/services/data/' + apiVersion + '/tooling/query/?q=';
    }


}