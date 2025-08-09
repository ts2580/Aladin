/************************************************************************************
 * File Name        : S4_Util.cls
 * Author           : 한성진
 * Date             : 2024-08-22
 * Tester           : S4_Util_test.cls
 * Target           :
 * Description      : 스크럼4 주관. 유틸성으로 사용.
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2024-08-22      한성진           Create
   1.1      2024-08-27      한성진           필드 생성 메서드 고도화
   1.2      2024-08-29      한성진           필드 자동 배포 로직 생성
   1.3      2024-09-03      한성진           로그인 IP 제한으로 인한 자동배포 메서드 개발 중단. 화면에서 코드 조회하도록 개발 시작
   1.4      2024-09-04      한성진           픽리스트 배포 기능 추가
   1.5      2024-09-12      한성진           url, phone 배포 기능 추가
   1.6      2024-09-19      한성진           노티 추가
   1.7      2024-09-30      한성진           글자/숫자 수식 필드 배포 추가
   2.0      2024-10-30      한성진           describe sobjects API와 CustomField ToolingAPI 조합해서 안나오는 필드들 나오도록 함
   2.1      2024-11-11      한성진           visibleLine, Description 안나오던 버그 수정
   2.2      2024-11-12      한성진           relationshipName 이상하게 들어가던 버그 수정 및 코드 정리
*************************************************************************************/
public with sharing class S4_Util {

    /**
     *  오브젝트의 모든 필드를 가져올 때 사용.
     *  @param strObjectName {string} - 오브젝트 이름
     *  @return {string} - 필드를 ","로 이어붙인것
     */
    public static String getAllFieldsStr(String strObjectName) {
        SObjectType objType = Schema.getGlobalDescribe().get(strObjectName);
        Map<String, Schema.SObjectField> mfields = objType.getDescribe().fields.getMap();
        String targetFields = ' ';
        for (String key : mfields.keySet()) {
            targetFields += String.valueOf(mfields.get(key)) + ', ';
        }
        return targetFields.removeEnd(', ') + ' ';
    }

    /**
     * Excel 생성용.
     */
    private class PrimeMetadata{
        public List<CustomFieldMetadataExcel> records;
    }

    private class CustomFieldMetadataExcel {
        public String DeveloperName;
        public String RelationshipLabel;
        public String Description;
        public Integer Precision;
        public String FullName;
        public Metadata Metadata;
    }

    /**
     * 필드를 만들어보자. ToolingApI의 CustomField 생성 규격. Insert용.
     */
    private class CustomFieldMetadata {

        public String FullName;
        public Metadata Metadata;

        /**
         * CustomField 생성 규격에 맞춘 Object
         * @param objectName {String} - 오브젝트 API명
         * @param fieldName {String} - 필드 API명
         * @param fieldLabel {String} - 필드 라벨
         * @param description {String} - 설명
         * @param length {Integer} - Text 계열 필드일 때 길이
         * @param precision {Integer} - Number일 때 길이
         * @param visibleLines {Integer} - TextArea 계열 필드일 시 보여질 라인
         * @param scale {Integer} - Number일 때 소숫점 자릿수
         * @param type {String} - 필드 타입
         * @param referenceTo {String} - Lookup 필드일 시 설정. 참조할 오브젝트
         * @param relationshipName {String} - Lookup 필드일 시 설정. 상위에서 하위 부를 때 사용
         * @param deleteConstraint {String} - MasterDetail 필드 레코드 삭제시 행동. Cascade, Restrict, SetNull
         * @param defaultValue {String} - 기본값
         * @param required {Boolean} - 필수 여부
         * @param formula {String} - 수식
         */
        public CustomFieldMetadata(
                String objectName,
                String fieldName,
                String fieldLabel,
                String description,
                Integer length,
                Integer precision,
                Integer visibleLines,
                Integer scale,
                String type,
                String referenceTo,
                String relationshipName,
                String deleteConstraint,
                String defaultValue,
                Boolean required,
                String formula

        ) {
            this.FullName = objectName + '.' + fieldName;
            this.Metadata = new Metadata(fieldLabel, description, length, precision, visibleLines, scale, type, referenceTo, relationshipName, deleteConstraint, defaultValue, required, formula);
        }
    }


    private class Metadata {
        public String label;
        public String description;
        public Integer length;
        public Integer precision;
        public Integer visibleLines;
        public Integer scale;
        public String type;
        public String referenceTo;
        public String relationshipName;
        public String deleteConstraint;
        public String defaultValue;
        public Boolean required;
        public String formula;

        /**
         * @param label {String} - 필드 라벨
         * @param description {String} - 설명
         * @param length {Integer} - Text 계열 필드일 때 길이
         * @param precision {Integer} - Number일 때 길이
         * @param visibleLines {Integer} - TextArea 계열 필드일 시 보여질 라인
         * @param scale {Integer} - Number일 때 소숫점 자릿수
         * @param type {String} - 필드 타입
         * @param referenceTo {String} - Lookup 필드일 시 설정. 참조할 오브젝트
         * @param relationshipName {String} - Lookup 필드일 시 설정. 상위에서 하위 부를 때 사용
         * @param deleteConstraint {String} - Lookup 필드 레코드 삭제시 행동. Cascade, Restrict, SetNull
         * @param defaultValue {String} - 기본값
         * @param required {Boolean} - 필수 여부
         * @param formula {String} - 수식
         */

        public Metadata(String label, String description, Integer length, Integer precision, Integer visibleLines, Integer scale, String type, String referenceTo, String relationshipName, String deleteConstraint, String defaultValue, Boolean required, String formula) {
            this.label = label;
            this.description = description;
            this.length = length;
            this.precision = precision;
            this.visibleLines = visibleLines;
            this.scale = scale;
            this.type = type;
            this.referenceTo = referenceTo;
            this.relationshipName = relationshipName;
            this.deleteConstraint = deleteConstraint;
            this.defaultValue = defaultValue;
            this.required = required;
            this.formula = formula;
        }
    }

    /**
     * DateField 필드 생성시 호출
     * @param objectNM {String} - 오브젝트 API명
     * @param fieldLabel {String} - 필드 라벨
     * @param fieldNm {String} - 필드 API명
     * @param description {String} - 설명
     * @param defaultValue {String} - 기본값
     * @param required {Boolean} - 필수 여부
     * @param type {String} - 필드타입. date, phone, url은 생성 파라미터가 같음
     * @return res {String} - 리스폰스 리턴
     */
    public static String setCustomDatePhoneUrlField(
            String objectNM,
            String fieldLabel,
            String fieldNm,
            String description,
            String defaultValue,
            Boolean required,
            String type

    ) {

        if (type.equals('phone')) {
            type = 'Phone';
        } else if (type.equals('url')) {
            type = 'Url';
        } else if (type.equals('date')) {
            type = 'Date';
        }

        return setCustomField(objectNM, fieldLabel, fieldNm, description, null, null, null, null, type, null, null, null, defaultValue, required, null);
    }

    /**
     * DateTimeField 필드 생성시 호출
     * @param objectNM {String} - 오브젝트 API명
     * @param fieldLabel {String} - 필드 라벨
     * @param fieldNm {String} - 필드 API명
     * @param description {String} - 설명
     * @param defaultValue {String} - 기본값
     * @param required {Boolean} - 필수 여부
     * @return res {String} - 리스폰스 리턴
     */
    public static String setCustomDateTimeField(
            String objectNM,
            String fieldLabel,
            String fieldNm,
            String description,
            String defaultValue,
            Boolean required
    ) {
        return setCustomField(objectNM, fieldLabel, fieldNm, description, null, null, null, null, 'DateTime', null, null, null, defaultValue, required, null);
    }

    /**
     * NumberField 필드 생성시 호출
     * @param objectNM {String} - 오브젝트 API명
     * @param fieldLabel {String} - 필드 라벨
     * @param fieldNm {String} - 필드 API명
     * @param description {String} - 설명
     * @param precision {Integer} - 길이
     * @param scale {Integer} - 소숫점 자릿수
     * @param defaultValue {String} - 기본값
     * @param required {Boolean} - 필수 여부
     * @return res {String} - 리스폰스 리턴
     */
    public static String setCustomNumberField(
            String objectNM,
            String fieldLabel,
            String fieldNm,
            String description,
            Integer precision,
            Integer scale,
            String defaultValue,
            Boolean required
    ) {
        return setCustomField(objectNM, fieldLabel, fieldNm, description, null, null, precision, scale, 'Number', null, null, null, defaultValue, required, null);
    }

    /**
     * PercentField 필드 생성시 호출
     * @param objectNM {String} - 오브젝트 API명
     * @param fieldLabel {String} - 필드 라벨
     * @param fieldNm {String} - 필드 API명
     * @param description {String} - 설명
     * @param precision {Integer} - 길이
     * @param scale {Integer} - 소숫점 자릿수
     * @param defaultValue {String} - 기본값
     * @param required {Boolean} - 필수 여부
     * @return res {String} - 리스폰스 리턴
     */
    public static String setCustomPercentField(
            String objectNM,
            String fieldLabel,
            String fieldNm,
            String description,
            Integer precision,
            Integer scale,
            String defaultValue,
            Boolean required
    ) {
        return setCustomField(objectNM, fieldLabel, fieldNm, description, null, null, precision, scale, 'Percent', null, null, null, defaultValue, required, null);
    }

    /**
     * CurrencyField 필드 생성시 호출
     * @param objectNM {String} - 오브젝트 API명
     * @param fieldLabel {String} - 필드 라벨
     * @param fieldNm {String} - 필드 API명
     * @param description {String} - 설명
     * @param precision {Integer} - 길이
     * @param scale {Integer} - 소숫점 자릿수
     * @param defaultValue {String} - 기본값
     * @param required {Boolean} - 필수 여부
     * @return res {String} - 리스폰스 리턴
     */
    public static String setCustomCurrencyField(
            String objectNM,
            String fieldLabel,
            String fieldNm,
            String description,
            Integer precision,
            Integer scale,
            String defaultValue,
            Boolean required
    ) {
        return setCustomField(objectNM, fieldLabel, fieldNm, description, null, null, precision, scale, 'Currency', null, null, null, defaultValue, required, null);
    }

    /**
     * TextField 필드 생성시 호출
     * @param objectNM {String} - 오브젝트 API명
     * @param fieldLabel {String} - 필드 라벨
     * @param fieldNm {String} - 필드 API명
     * @param description {String} - 설명
     * @param length {Integer} - 길이
     * @param defaultValue {String} - 기본값
     * @param required {Boolean} - 필수 여부
     * @return res {String} - 리스폰스 리턴
     */
    public static String setCustomTextField(
            String objectNM,
            String fieldLabel,
            String fieldNm,
            String description,
            Integer length,
            String defaultValue,
            Boolean required
    ) {
        return setCustomField(objectNM, fieldLabel, fieldNm, description, length, null, null, null, 'Text', null, null, null, defaultValue, required, null);
    }

    /**
     * LongTextArea 필드 생성시 호출
     * @param objectNM {String} - 오브젝트 API명
     * @param fieldLabel {String} - 필드 라벨
     * @param fieldNm {String} - 필드 API명
     * @param description {String} - 설명
     * @param length {Integer} - 길이
     * @param visibleLines {Integer} - 보여질 라인
     * @param defaultValue {String} - 기본값
     * @return res {String} - 리스폰스 리턴
     */
    public static String setCustomLongTextAreaField(
            String objectNM,
            String fieldLabel,
            String fieldNm,
            String description,
            Integer length,
            Integer visibleLines,
            String defaultValue
    ) {
        String type;
        if (length > 255) {
            type = 'LongTextArea';
        } else {
            type = 'TextArea';
            length = null;
            visibleLines = null;
        }

        return setCustomField(objectNM, fieldLabel, fieldNm, description, length, visibleLines, null, null, type, null, null, null, defaultValue, false, null);
    }

    /**
     * Lookup 필드 생성시 호출
     * @param objectNM {String} - 오브젝트 API명
     * @param fieldLabel {String} - 필드 라벨
     * @param fieldNm {String} - 필드 API명
     * @param description {String} - 설명
     * @param referenceTo {String} - Lookup 필드일 시 설정. 참조할 오브젝트
     * @param relationshipName {String} - Lookup 필드일 시 설정. 상위에서 하위 부를 때 사용
     * @param deleteConstraint {Integer} - Lookup 필드 레코드 삭제시 행동. Cascade, Restrict, SetNull
     * @param required {Boolean} - 필수 여부
     * @param type {Boolean} - 마스터-디테일임? 아님 룩업?
     * @return res {String} - 리스폰스 리턴
     */
    public static String setCustomLookup(
            String objectNM,
            String fieldLabel,
            String fieldNm,
            String description,
            String referenceTo,
            String relationshipName,
            String deleteConstraint,
            Boolean required,
            String type
    ) {
        deleteConstraint = null;

        return setCustomField(objectNM, fieldLabel, fieldNm, description, null, null, null, null, type, referenceTo, relationshipName, deleteConstraint, null, required, null);
    }

    /**
     * Lookup 필드 생성시 호출
     * @param objectNM {String} - 오브젝트 API명
     * @param fieldLabel {String} - 필드 라벨
     * @param fieldNm {String} - 필드 API명
     * @param description {String} - 설명
     * @param defaultValue {String} - 기본값 true/false
     * @return res {String} - 리스폰스 리턴
     */
    public static String setCustomBoolean(
            String objectNM,
            String fieldLabel,
            String fieldNm,
            String description,
            String defaultValue

    ) {
        return setCustomField(objectNM, fieldLabel, fieldNm, description, null, null, null, null, 'Checkbox', null, null, null, 'false', null, null);
    }

    // 이하 PickList 생성용 클래스
    private class ToolingValueSet {
        public String fullName;
        public ValueSetMetadata metadata;
    }

    private class ValueSetMetadata {
        public String label;
        public String type = 'Picklist';
        public ValueSet valueSet;
    }

    private class ValueSet {
        public ValueSetDefinition valueSetDefinition;
    }

    private class ValueSetDefinition {
        List<Value> value;
    }

    private class Value {
        public String color;
        public String description;
        public Boolean isActive;
        public String label;
        public String valueName;
    }

    // 픽리스트는 생성시 Obj를 받아야 하기 때문에 문자열 파라미터로 넘기기 곤란. 통으로 JSON으로 말자.
    public static String setCustomPicklist(String json, String objName, String fieldNm) {

        String returnString;

        HttpRequest req = new HttpRequest();
        req.setBody(json);
        if (Test.isRunningTest()) {
            req.setHeader('Authorization', 'Bearer 1234');
        } else {
            req.setHeader('Authorization', 'Bearer ' + Page.VF_SessionId.getContent().toString());
        }

        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + '/services/data/v61.0/tooling/sobjects/CustomField/');
        req.setMethod('POST');

        Http http = new Http();
        HttpResponse res = http.send(req);

        returnString = res.getBody();

        if (res.getStatusCode() == 400) {
            returnString = fieldUpdt(res.getBody(), objName, fieldNm, json);
        }

        return returnString;
    }

    /**
     * Formula 필드 생성시 호출
     * @param objectNM {String} - 오브젝트 API명
     * @param fieldLabel {String} - 필드 라벨
     * @param fieldNm {String} - 필드 API명
     * @param description {String} - 설명
     * @param type {String} - 종류
     * @param length {Integer} - Text 계열 필드일 때 길이
     * @param precision {Integer} - 길이
     * @param scale {Integer} - 소숫점 자릿수
     * @param calculatedFormula {String} - 수식
     * @return res {String} - 리스폰스 리턴
     */
    public static String setCustomFormula(
            String objectNM,
            String fieldLabel,
            String fieldNm,
            String description,
            String type,
            Integer length,
            Integer precision,
            Integer scale,
            String calculatedFormula
    ) {
        if (type.equals('Number')) {
            type = 'Number';
            length = null;
        } else if (type.equals('Text')) {
            type = 'Text';
            precision = null;
            scale = null;
        }

        return setCustomField(objectNM, fieldLabel, fieldNm, description, length, null, precision, scale, type, null, null, null, null, null, calculatedFormula);
    }

    /**
     * 필드를 만드는 본 메서드
     * @param objectNM {String} - 오브젝트 API명
     * @param fieldLabel {String} - 필드 라벨
     * @param fieldNm {String} - 필드 API명
     * @param description {String} - 설명
     * @param length {Integer} - Text 계열 필드일 때 길이
     * @param visibleLines {Integer} - TextArea 계열 필드일 시 보여질 라인
     * @param precision {Integer} - Number일 때 길이
     * @param scale {Integer} - Number일 때 소숫점 자릿수
     * @param type {String} - 필드 타입
     * @param referenceTo {String} - Lookup 필드일 시 설정. 참조할 오브젝트
     * @param relationshipName {String} - Lookup 필드일 시 설정. 상위에서 하위 부를 때 사용
     * @param deleteConstraint {String} - Lookup 필드 레코드 삭제시 행동. Cascade, Restrict, SetNull
     * @param defaultValue {String} - 기본값
     * @param required {Boolean} - 필수 여부
     * @param formula {String} - 수식
     * @return res {String} - 리스폰스 리턴
     */
    private static String setCustomField(
            String objectNM,
            String fieldLabel,
            String fieldNm,
            String description,
            Integer length,
            Integer visibleLines,
            Integer precision,
            Integer scale,
            String type,
            String referenceTo,
            String relationshipName,
            String deleteConstraint,
            String defaultValue,
            Boolean required,
            String formula
    ) {
        String returnString;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + '/services/data/v61.0/tooling/sobjects/CustomField/');
        req.setMethod('POST');
        if (Test.isRunningTest()) {
            req.setHeader('Authorization', 'Bearer 12345');
        } else {
            req.setHeader('Authorization', 'Bearer ' + Page.VF_SessionId.getContent().toString());
        }
        req.setHeader('Content-Type', 'application/json');

        String requestBody = JSON.serialize(
                new CustomFieldMetadata(objectNM, fieldNm + '__c', fieldLabel, description, length, precision, visibleLines, scale, type, referenceTo, relationshipName, deleteConstraint, defaultValue, required, formula)
        );

        req.setBody(requestBody);

        Http http = new Http();
        HttpResponse res = http.send(req);

        returnString = res.getBody();

        if (res.getStatusCode() == 400) {
            returnString = fieldUpdt(res.getBody(), objectNM, fieldNm, requestBody);
        }

        return returnString;
    }

    private static String fieldUpdt(String resBody, String objectNM, String fieldNm, String reqBody) {

        String returnString = resBody;

        List<Object> listReturn = (List<Object>) JSON.deserializeUntyped(resBody);
        Map<String, Object> mapReturn = (Map<String, Object>) listReturn[0];

        if (String.valueOf(mapReturn.get('message')).contains('There is already a field')) {

            String query = 'select Id from CustomField where EntityDefinition.DeveloperName = \'' + objectNM.replace('__c', '') + '\' and DeveloperName = \'' + fieldNm + '\'';

            HttpRequest req = new HttpRequest();
            req.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + '/services/data/v61.0/tooling/query/?q=' + EncodingUtil.urlEncode(query, 'UTF-8'));
            req.setMethod('GET');
            if (Test.isRunningTest()) {
                req.setHeader('Authorization', 'Bearer 1234');
            } else {
                req.setHeader('Authorization', 'Bearer ' + Page.VF_SessionId.getContent().toString());
            }
            req.setHeader('Content-Type', 'application/json');

            Http http = new Http();
            HttpResponse res = http.send(req);

            mapReturn = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            listReturn = (List<Object>) mapReturn.get('records');
            mapReturn = (Map<String, Object>) listReturn[0];

            req = new HttpRequest();
            req.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + '/services/data/v61.0/tooling/sobjects/CustomField/' + mapReturn.get('Id'));
            req.setMethod('PATCH');
            if (Test.isRunningTest()) {
                req.setHeader('Authorization', 'Bearer 1234');
            } else {
                req.setHeader('Authorization', 'Bearer ' + Page.VF_SessionId.getContent().toString());
            }
            req.setHeader('Content-Type', 'application/json');
            req.setBody(reqBody);

            http = new Http();
            res = http.send(req);
            returnString = res.getBody();
        }

        return returnString;
    }

    private class DescribeReturn{
        public List<field> fields;
    }


    public class field {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String description;
        @AuraEnabled
        public Integer length;
        @AuraEnabled
        public Integer precision;
        @AuraEnabled
        public Integer visibleLines;
        @AuraEnabled
        public Integer scale;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public Boolean custom;
        @AuraEnabled
        public List<String> referenceTo;
        @AuraEnabled
        public String relationshipName;
        @AuraEnabled
        public String deleteConstraint;
        @AuraEnabled
        public String defaultValue;
        @AuraEnabled
        public String calculatedFormula;
        @AuraEnabled
        public Boolean required;
        @AuraEnabled
        public List<PicklistValues> picklistValues;
        @AuraEnabled
        public String picklistString;
        @AuraEnabled
        public String referenceString;
        @AuraEnabled
        public Boolean isMaster;
    }

    private class PicklistValues {
        public String value;
        public String label;
        public Boolean defaultValue;
        public Boolean active;
    }

    /**
     * @param objName - 필드 생성 쿼리를 가져오고자 하는 Obj
     * @return List<String> - 필드 배포 코드 뭉치 사고 뭉치
     */
    @AuraEnabled
    public static List<field> fieldDeployPipeline(String objName) {

        String INSTANCE_URL = Url.getOrgDomainUrl().toExternalForm() + '/services/data/v61.0/sobjects/' + objName + '/describe';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(INSTANCE_URL);
        req.setMethod('GET');
        if (Test.isRunningTest()) {
            req.setHeader('Authorization', 'Bearer 1234');
        } else {
            req.setHeader('Authorization', 'Bearer ' + Page.VF_SessionId.getContent().toString());
        }
        req.setHeader('Content-Type', 'application/json');

        Http http = new Http();
        HttpResponse res = http.send(req);

        DescribeReturn describeReturn = (DescribeReturn) JSON.deserialize(res.getBody(), DescribeReturn.class);
        List<field> listFields = new List<field>();

        Set<String> setReferenceFields = new Set<String>();
        for (field field : describeReturn.fields) {
            if(field.custom){
                if(field.type == 'reference'){
                    setReferenceFields.add(field.name.replace('__c',''));
                }
            }
        }

        Map<String, Map<String, String>> mapFieldDes = getFieldDescription(objName, setReferenceFields);
        Map<String, String> mapParam;
        for (field field : describeReturn.fields) {
            if(field.custom){
                mapParam = mapFieldDes.get(field.name);
                field.description = mapFieldDes.get(field.name).get('description');

                if(field.type == 'picklist'){
                    field.picklistString = setPicklistJSON(objName, field);
                }else if(field.type == 'reference'){
                    field.referenceString = field.referenceTo[0];
                    field.type = mapParam.get('type');
                    field.relationshipName = mapParam.get('relationshipName');
                }

                // LongText Field의 visibleLines은 CustomField API의 precision에 숨어있다. 왜?
                if(field.length > 255 && String.isNotEmpty(mapParam.get('precision'))) {
                    field.visibleLines = Integer.valueOf(mapParam.get('precision'));
                }

                listFields.add(field);
            }
        }

        System.debug(JSON.serialize(listFields));

        return listFields;
    }

    private static Map<String, Map<String, String>> getFieldDescription(String objNm, Set<String> setReferenceFields) {

        Map<String, Map<String, String>> mapReturn = new Map<String, Map<String, String>>();

        String toolingSoql =
                'SELECT Id, DeveloperName, Description, Length, Precision, RelationshipLabel ' +
                        'FROM CustomField  ' +
                        'WHERE EntityDefinition.QualifiedApiName =\'' + objNm + '\'';
        String toolingSoqlSafe = EncodingUtil.urlEncode(toolingSoql, 'UTF-8');

        String INSTANCE_URL = Url.getOrgDomainUrl().toExternalForm() + '/services/data/v62.0/tooling/query/?q=' + toolingSoqlSafe;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(INSTANCE_URL);
        req.setMethod('GET');
        if (Test.isRunningTest()) {
            req.setHeader('Authorization', 'Bearer 1234');
        } else {
            req.setHeader('Authorization', 'Bearer ' + Page.VF_SessionId.getContent().toString());
        }
        req.setHeader('Content-Type', 'application/json');

        Http http = new Http();
        HttpResponse res = http.send(req);

        PrimeMetadata primeMetadata;

        primeMetadata = (PrimeMetadata) JSON.deserialize(res.getBody(), PrimeMetadata.class);

        Map<String, String> mapInnerParam;
        for (CustomFieldMetadataExcel record : primeMetadata.records) {

            if(!record.DeveloperName.contains('_del')){
                mapInnerParam = new Map<String, String>();
                mapInnerParam.put('description', record.Description);
                mapInnerParam.put('precision', String.valueOf(record.Precision));

                mapReturn.put(record.DeveloperName + '__c', mapInnerParam);
            }
        }

        // 릴레이션 필드의 relationshipName 가져오기. 쿼리에 조건만 추가하고 나머지는 재사용
        if(setReferenceFields.size() > 0){
            for (String developerName : setReferenceFields) {
                toolingSoql =
                        'SELECT Id, DeveloperName, Metadata ' +
                                'FROM CustomField  ' +
                                'WHERE EntityDefinition.QualifiedApiName =\'' + objNm + '\' ' +
                                'AND DeveloperName =\'' + developerName + '\'';
                toolingSoqlSafe = EncodingUtil.urlEncode(toolingSoql, 'UTF-8');
                INSTANCE_URL = Url.getOrgDomainUrl().toExternalForm() + '/services/data/v62.0/tooling/query/?q=' + toolingSoqlSafe;
                req.setEndpoint(INSTANCE_URL);
                http = new Http();
                res = http.send(req);

                primeMetadata = (PrimeMetadata) JSON.deserialize(res.getBody(), PrimeMetadata.class);

                for (CustomFieldMetadataExcel record : primeMetadata.records) {
                    mapInnerParam = mapReturn.get(developerName + '__c');
                    mapInnerParam.put('type', record.Metadata.type);
                    mapInnerParam.put('relationshipName', record.Metadata.relationshipName);

                    mapReturn.put(developerName + '__c', mapInnerParam);
                }
            }
        }

        return mapReturn;
    }

    private static String setPicklistJSON(String objName, field field2){
        ToolingValueSet tgv = new ToolingValueSet();
        tgv.fullName = objName + '.' +field2.name;

        List<Value> listValue = new List<Value>();
        List<PicklistValues> pickListValue = field2.picklistValues;

        for (PicklistValues picklistValues : pickListValue) {
            Value value = new Value();
            value.label = picklistValues.label;
            value.valueName = picklistValues.value;
            value.isActive = picklistValues.active;
            listValue.add(value);
        }

        ValueSetMetadata gvm = new ValueSetMetadata();
        gvm.label = field2.label;

        ValueSet valueSet = new ValueSet();

        ValueSetDefinition valueSetDefinition = new ValueSetDefinition();
        valueSetDefinition.value = listValue;

        valueSet.valueSetDefinition = valueSetDefinition;

        gvm.valueSet = valueSet;

        tgv.metadata = gvm;

        return JSON.serialize(tgv);
    }

    @AuraEnabled
    public static List<String> insertFields(List<Object> listField) {
        List<String> listReturnParam = new List<String>();

        Map<Object, Object> mapObj;
        Map<String, Object> mapStringObj;
        Map<String, Object> mapStringObj2;
        String picklistString;
        String type;
        String objName;
        String label;
        String fieldNm;
        String description;
        Integer length;
        Integer precision;
        Integer scale;
        Integer visibleLines;
        String calculatedFormula;
        String defaultValue;
        String referenceString;
        String relationshipName;

        for (Object obj : listField) {
            mapObj = (Map<Object, Object>) obj;
            picklistString = mapObj.get('picklistString') == null ? null : String.valueOf(mapObj.get('picklistString'));
            type = String.valueOf(mapObj.get('type'));
            objName = String.valueOf(mapObj.get('targetObj'));
            label = String.valueOf(mapObj.get('label'));
            fieldNm = String.valueOf(mapObj.get('name')).replace('__c', '');
            length = mapObj.get('length') == null ? null : Integer.valueOf(mapObj.get('length'));
            visibleLines = mapObj.get('visibleLines') == null ? null : Integer.valueOf(mapObj.get('visibleLines'));
            precision = mapObj.get('precision') == null ? null : Integer.valueOf(mapObj.get('precision'));
            scale = mapObj.get('scale') == null ? null : Integer.valueOf(mapObj.get('scale'));
            calculatedFormula = mapObj.get('calculatedFormula') == null ? null : String.valueOf(mapObj.get('calculatedFormula'));
            description = mapObj.get('description') == null ? null : String.valueOf(mapObj.get('description'));
            referenceString = mapObj.get('referenceString') == null ? null : String.valueOf(mapObj.get('referenceString'));
            relationshipName = mapObj.get('relationshipName') == null ? null : String.valueOf(mapObj.get('relationshipName'));
            defaultValue = null;

            if (String.isNotEmpty(calculatedFormula)) {
                listReturnParam.add(setCustomFormula(objName, label, fieldNm, description, type, length, precision, scale, calculatedFormula));
            } else if (type.equals('Number')) {
                listReturnParam.add(setCustomNumberField(objName, label, fieldNm, description, precision, scale, defaultValue, false));
            } else if (type.equals('Text')) {
                listReturnParam.add(setCustomTextField(objName, label, fieldNm, description, length, defaultValue, false));
            } else if (type.equals('Date') || type.equals('Phone') || type.equals('Url')) {
                listReturnParam.add(setCustomDatePhoneUrlField(objName, label, fieldNm, description, defaultValue, false, type));
            } else if (type.equals('DateTime')) {
                listReturnParam.add(setCustomDateTimeField(objName, label, fieldNm, description, defaultValue, false));
            } else if (type.equals('Percent')) {
                listReturnParam.add(setCustomPercentField(objName, label, fieldNm, description, precision, scale, defaultValue, false));
            } else if (type.equals('currency')) {
                listReturnParam.add(setCustomCurrencyField(objName, label, fieldNm, description, precision, scale, defaultValue, false));
            } else if (type.equals('LongTextArea')) {
                listReturnParam.add(setCustomLongTextAreaField(objName, label, fieldNm, description, length, visibleLines, defaultValue));
            } else if (type.equals('Lookup') || type.equals('MasterDetail')) {
                listReturnParam.add(setCustomLookup(objName, label, fieldNm, description, referenceString, relationshipName.replace('__r', ''), 'SetNull', false, type));
            } else if (type.equals('Checkbox')) {
                listReturnParam.add(setCustomBoolean(objName, label, fieldNm, description, defaultValue));
            } else if (type.equals('picklist')) {

                mapStringObj = (Map<String, Object>) JSON.deserializeUntyped(picklistString);

                mapStringObj.put('fullName', objName + '.' + fieldNm + '__c');

                mapStringObj2 = (Map<String, Object>) mapStringObj.get('metadata');
                mapStringObj2.put('label', label);

                mapStringObj.put('metadata', mapStringObj2);

                listReturnParam.add(setCustomPicklist(JSON.serialize(mapStringObj), objName.replace('__c', ''), fieldNm));
            } else {
                listReturnParam.add(JSON.serialize(new List<Map<String, Object>>{
                        new Map<String, Object>{
                                'message' => '개발중인 필드타입'
                        }
                }));
            }
        }

        return listReturnParam;
    }

    @AuraEnabled(Cacheable=true)
    public static List<String> getAllObjName() {

        // Schema.SObjectType으로 불러올까 Describe Global API를 써볼까
        // 대세는 API

        List<String> listCode = new List<String>();

        String INSTANCE_URL = Url.getOrgDomainUrl().toExternalForm() + '/services/data/v61.0/sobjects/';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(INSTANCE_URL);
        req.setMethod('GET');
        if (Test.isRunningTest()) {
            req.setHeader('Authorization', 'Bearer 1234');
        } else {
            req.setHeader('Authorization', 'Bearer ' + Page.VF_SessionId.getContent().toString());
        }
        req.setHeader('Content-Type', 'application/json');

        Http http = new Http();
        HttpResponse res = http.send(req);

        Map<String, Object> mapReturn = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

        List<Object> listObject = (List<Object>) mapReturn.get('sobjects');

        for (Object sobjects : listObject) {
            mapReturn = (Map<String, Object>) sobjects;
            listCode.add(String.valueOf(mapReturn.get('name')));
        }

        return listCode;
    }

    /**
     * Log Id 가져오는 메서드. 2주일치 로그 검색 가능
     * @param yyyymmdd {String} - YYYY-DD-MM 형식의 날짜
     * @return {String} - 로그의 Id
     */
    public static List<ApexLog> getLogMeta(String yyyymmdd) {

        List<ApexLog> listApexLog = [
                SELECT Id, FORMAT(StartTime), LogUser.Name, Status
                FROM ApexLog
                WHERE DAY_ONLY(StartTime) = :Date.valueOf(yyyymmdd)
                ORDER BY StartTime DESC
        ];

        for (ApexLog obj : listApexLog) {
            System.debug(obj.Id + ' ' + obj.LogUser.Name + ' ' + obj.StartTime.addHours(9) + ' : ' + obj.Status);
        }

        return listApexLog;
    }

    /**
     * @param logId {String} - 로그의  Id
     * @return {String} - 로그의 내용
     */
    public static String getLog(String logId) {

        String strEndPoint = Url.getOrgDomainUrl().toExternalForm() + '/services/data/v61.0/tooling/sobjects/ApexLog/' + logId + '/Body';

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        if (Test.isRunningTest()) {
            req.setHeader('Authorization', 'Bearer 1234');
        } else {
            req.setHeader('Authorization', 'Bearer ' + Page.VF_SessionId.getContent().toString());
        }
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(strEndPoint);
        req.setMethod('GET');
        HttpResponse res = http.send(req);

        String debug = res.getBody().toString();

        System.debug(debug.replace('|', ':'));

        return res.getBody();
    }

    public class PageRef {
        public String type;
        public RefAttributes attributes;
        public RefState state;
    }

    public class RefAttributes {
        public String objectApiName;
        public String actionName;
        public String url;
        public String apiName;
    }

    public class RefState {
        public String filterName;
    }

    /**
     *  @param listEmail {List<String>} - 유저들의 List<String> Email
     *  @param title - 노티 제목
     *  @param message - 노티 내용
     *  https://developer.salesforce.com/docs/platform/lwc/guide/reference-page-reference-type.html
     *  페이지 이동위한 PageReference 가이드 문서
     *  레코드 페이지로 가고 싶으면 notification.setTargetPageRef() 제거 후 notification.setTargetId() 에 레코드 Id 넣어주면 됨
     */
    public static void sendNotification(List<String> listEmail, String title, String message) {

        CustomNotificationType notificationType = [
                SELECT Id, DeveloperName
                FROM CustomNotificationType
                WHERE DeveloperName = 'Message'
        ];

        List<User> listUser = [
                SELECT Id, Email
                FROM User
                WHERE Email IN :listEmail
        ];
        Set<String> setUserIds = new Set<String>();

        for (User user : listUser) {
            setUserIds.add(user.Id);
        }

        /*PageRef pageRef = new PageRef();
        pageRef.type = 'standard__objectPage';

        RefAttributes refAttributes = new RefAttributes();
        refAttributes.objectApiName = 'POS_OM_HEADER__c';
        refAttributes.actionName = 'list';

        RefState refState = new RefState();
        refState.filterName = 'NoSalesContract';

        pageRef.attributes = refAttributes;
        pageRef.state = refState;*/

        PageRef pageRef = new PageRef();
        pageRef.type = 'standard__webPage';

        RefAttributes refAttributes = new RefAttributes();
        refAttributes.url = Url.getOrgDomainUrl() + '/lightning/n/Order';

        pageRef.attributes = refAttributes;

        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle(title);
        notification.setBody(message);
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetPageRef(JSON.serialize(pageRef));
        notification.send(setUserIds);
    }

    @AuraEnabled(Cacheable=true)
    public static List<String> getClass(){
        List<String> listReturnStrings = new List<String>();
        List<ApexClass> listApexClasses = [
                SELECT Id, Name
                FROM ApexClass
        ];
        for (ApexClass obj : listApexClasses) {
            listReturnStrings.add(obj.Name);
        }
        return listReturnStrings;
    }

    @AuraEnabled(Cacheable=true)
    public static List<String> getLwc(){
        List<String> listReturnStrings = new List<String>();
        String toolingSoql =
                'SELECT LightningComponentBundle.DeveloperName ' +
                        'FROM LightningComponentResource ' +
                        'WHERE ManageableState =\'unmanaged\' ' +
                        'group by LightningComponentBundle.DeveloperName ' +
                        'ORDER BY LightningComponentBundle.DeveloperName ';
        String toolingSoqlSafe = EncodingUtil.urlEncode(toolingSoql, 'UTF-8');
        String INSTANCE_URL = Url.getOrgDomainUrl().toExternalForm() + '/services/data/v62.0/tooling/query/?q=' + toolingSoqlSafe;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(INSTANCE_URL);
        req.setMethod('GET');
        if (Test.isRunningTest()) {
            req.setHeader('Authorization', 'Bearer 12345');
        } else {
            req.setHeader('Authorization', 'Bearer ' + Page.VF_SessionId.getContent().toString());
        }
        req.setHeader('Content-Type', 'application/json');
        Http http = new Http();
        HttpResponse res = http.send(req);
        Map<String,Object> mapReturn = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
        List<Object> listObject = (List<Object>) mapReturn.get('records');
        Map<String,Object> dn;
        for (Object obj : listObject) {
            dn = (Map<String,Object>) obj;
            listReturnStrings.add(String.valueOf(dn.get('DeveloperName')));
        }
        return listReturnStrings;
    }

}