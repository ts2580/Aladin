/************************************************************************************
 * File Name        : CM_ExcelExportController.cls
 * Author           : yr.Lee
 * Date             : 2024-06-20
 * Tester           : CM_ExcelExportController_test.cls
 * Target           :
 * Description      : 엑셀 다운로드
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2024-06-20      yr.Lee          Create
*************************************************************************************/
public with sharing class CM_ExcelExportController {
    public String strObjectAPI {get;set;}
    public String strFilterId {get;set;}
    public String queryAfterFrom {get;set;}
    public String listSelectedId {get;set;}

    private class ListviewQuery{
        public String sobjectType;
        public String query;
    }

    /* 생성자 */
    public CM_ExcelExportController(){}
    public CM_ExcelExportController(ApexPages.StandardSetController sc) {
        System.debug('[APEX] ExcelDownloadController 호출');

        strFilterId = sc.getFilterId();
        strObjectAPI = String.valueOf(sc.getRecord().getSObjectType());

        // 체크되어 넘어온 레코드가 있는가
        if(sc.getSelected().size() > 0){
            Set<Id> setIds = new Set<Id>();
            for (SObject obj : sc.getSelected()) {
                setIds.add(obj.Id);
            }

            listSelectedId = JSON.serialize(setIds);
        }else{
            String ep = Url.getOrgDomainUrl().toExternalForm() + '/services/data/v61.0/sobjects/'+ strObjectAPI +'/listviews/'+ strFilterId +'/describe';
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setHeader('Authorization','Bearer '+ UserInfo.getSessionId());
            req.setEndpoint(ep);
            HttpResponse res = new Http().send(req);

            ListviewQuery listview = (ListviewQuery) JSON.deserialize(res.getBody(), ListviewQuery.class);

            System.debug('리스트뷰 쿼리');
            System.debug(strFilterId);
            System.debug(listview.query);

            queryAfterFrom = listview.query.substringAfter(' FROM ').replace('\'','\\\'');
        }
    }

    // 체크한 데이터가 있을시 체크한것만 리턴
    @AuraEnabled
    public static List<Object> getExportData(List<String> listSelectedIds, String strObjectAPI) {
        System.debug('[APEX] getExportData 호출');
        System.debug('[APEX] listSelectedIds :: ' + listSelectedIds);
        System.debug('[APEX] strObjectAPI :: ' + strObjectAPI);

        List<Object> listReturn = new List<Object>();

        String fieldSetName = 'ExcelExport';
        List<String> listFieldSet = new List<String>();
        listFieldSet = DN_Util.getFieldSetForAPIName(strObjectAPI, fieldSetName);

        String strQuery;
        strQuery =  ' SELECT Id, ' + String.join(listFieldSet, ', ');
        strQuery += ' FROM   ' + strObjectAPI;
        strQuery += ' WHERE  Id IN: listSelectedIds Limit 49999';

        List<SObject> listQuery = new List<SObject>();
        listQuery = Database.query(strQuery);

        // Excel 다운로드 시 컬럼명이 API명이 아닌 Label명으로 출력
        Map<String, String> mapConvertToLabel = DN_Util.getFieldAPILabel(strObjectAPI);
        if (!listQuery.isEmpty()) {
            for (SObject obj : listQuery) {
                Map<String, Object> fieldMap = obj.getPopulatedFieldsAsMap();
                Map<String, Object> labeledFieldMap = new Map<String, Object>();

                for (String fieldName : fieldMap.keySet()) {
                    if (mapConvertToLabel.containsKey(fieldName)) {
                        String fieldLabel = mapConvertToLabel.get(fieldName);
                        labeledFieldMap.put(fieldLabel, fieldMap.get(fieldName));
                    }
                }
                listReturn.add(labeledFieldMap);
            }
        }
        System.debug('listReturn :: '+listReturn);

        return listReturn;
    }


    // 체크한 레코드가 없을 경우 리스트뷰 필터 조건에 맞는 모든 데이터 추출.
    // 일단 담보/채권 경우만 타는 코드 살짝 하드코딩 해놓음. 조건 명확해지면 하드코딩 날리고 getExportData 메서드와 합치기
    @AuraEnabled
    public static List<Object> getExportDataAll(String strQueryAfterFROM, String strObjectAPI) {
        System.debug('[APEX] getExportDataAll 호출');
        System.debug('[APEX] strObjectAPI :: ' + strObjectAPI);

        List<Object> listReturn = new List<Object>();

        String fieldSetName = 'ExcelExport';
        List<String> listFieldSet = new List<String>();
        listFieldSet = DN_Util.getFieldSetForAPIName(strObjectAPI, fieldSetName);

        String selectQuery = strObjectAPI == 'temp_BondCollateral__c' ? ' Name, fm_DepartmentCode__c, l_Department__r.DepartmentCode__c, l_Account__r.AccountCompanyCode__c, l_Department__r.Name, l_Account__r.Name, totalamount__c, fixedAmount__c, ShipmentAmount__c, CollateralAmount__c, ShipmentAmount2__c, CollateralRate__c, EstimateBond__c' : String.join(listFieldSet, ', ');

        String strQuery;
        strQuery =  ' SELECT Id, ' + selectQuery;
        strQuery += ' FROM   ' + strQueryAfterFROM + ' Limit 49999';

        System.debug('strQuery >>>>>>>>>'+strQuery);
        List<SObject> listQuery = new List<SObject>();
        listQuery = Database.query(strQuery);
        System.debug(JSON.serialize(listQuery));

        // Excel 다운로드 시 컬럼명이 API명이 아닌 Label명으로 출력

        Map<String, String> mapConvertToLabel = DN_Util.getFieldAPILabel(strObjectAPI);
        if (!listQuery.isEmpty()) {
            for (SObject obj : listQuery) {
                Map<String, Object> fieldMap = obj.getPopulatedFieldsAsMap();
                System.debug('obj.getPopulatedFieldsAsMap() >>>>>>>>'+obj.getPopulatedFieldsAsMap());
                Map<String, Object> labeledFieldMap = new Map<String, Object>();

                for (String fieldName : fieldMap.keySet()) {
                    if (mapConvertToLabel.containsKey(fieldName)) {
                        String fieldLabel = mapConvertToLabel.get(fieldName);
                        labeledFieldMap.put(fieldLabel, fieldMap.get(fieldName));

                        /*if(strObjectAPI == 'temp_BondCollateral__c'){

                            temp_BondCollateral__c objB = (temp_BondCollateral__c)  obj;
                            labeledFieldMap.put('Seq.', objB.Name);
                            labeledFieldMap.put('판매부서', objB.l_Department__r.DepartmentCode__c);
                            labeledFieldMap.put('부서명', objB.l_Department__r.Name);
                            labeledFieldMap.put('판매계약자', objB.l_Account__r.AccountCompanyCode__c);
                            labeledFieldMap.put('판매계약자명', objB.l_Account__r.Name);
                        }*/


                    }
                }
                listReturn.add(labeledFieldMap);
            }
        }
        System.debug('listReturn :: '+listReturn);

        return listReturn;
    }

    // IBsheet에서 데이터 말아서 던지면 한글 라벨로 갈아주는 메서드
    @AuraEnabled
    public static List<Object> getExportDataFromIBSheet(List<Object> listObject, String strObjectAPI) {
        System.debug('[APEX] getExportDataFromIBSheet 호출');

        List<Object> listReturn = new List<Object>();

        // Excel 다운로드 시 컬럼명이 API명이 아닌 Label명으로 출력
        Map<String, String> mapConvertToLabel = DN_Util.getFieldAPILabel(strObjectAPI);
        Map<Object, Object> mapObj;
        Map<String, Object> mapParam;
        String strKey;
        for (Object obj : listObject) {

            mapParam = new Map<String, Object>();
            mapObj = (Map<Object, Object>) obj;
            for (Object key : mapObj.keySet()){
                strKey = String.valueOf(key);
                mapParam.put(mapConvertToLabel.get(strKey), mapObj.get(strKey));
            }
            listReturn.add(mapParam);
        }

        return listReturn;
    }

    // listView 보여주는 페이지
    @AuraEnabled
    public static List<ListView> getOrgListviewId(String strObjectAPI){
        List<ListView> listviews = [
                SELECT  Id, Name, SobjectType
                FROM    ListView
                WHERE   SobjectType =: strObjectAPI
        ];

        return listviews;
    }
}