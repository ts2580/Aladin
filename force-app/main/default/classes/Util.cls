/**
 * Created by 한성진 on 2024-02-16.
 */

public with sharing class Util {

    public String getAllFieldsStr(String strObjectName){
        SObjectType objType = Schema.getGlobalDescribe().get(strObjectName);
        Map<String,Schema.SObjectField> mfields = objType.getDescribe().fields.getMap();
        String targetFields = '';
        for(String key : mfields.keySet()){
            targetFields += String.valueOf(mfields.get(key)) + ', ';
        }
        return targetFields.removeEnd(', ');
    }

    public static void getIp(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.ipify.org');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        String responseBody = response.getBody();
        System.debug(responseBody);
    }

}