/************************************************************************************
 * File Name        : DN_Util.cls
 * Author           : yr.Lee
 * Date             : 2024-05-29
 * Tester           : DN_Util_test.cls
 * Target           :
 * Description      : 유틸성으로 사용
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2024-05-29      yr.Lee          Create
   1.1      2024-08-21      kw.Jeon         Picklist/ Picklist Dependency 호출 메소드 추가
*************************************************************************************/
public with sharing class DN_Util {
    /**
     * @description object 별 Field Set 이용할 경우 사용
     * @param strObjectAPIName Object API 명
     * @param strFieldSetAPIName FieldSet 의 API 명
     *
     * @return List<Map<String, Object>> 필드셋 설정 정보 List
     */
    public static List<Map<String, Object>> getFieldSet(String strObjectAPIName, String strFieldSetAPIName) {
        List<Map<String, Object>> listReturnFieldSet = new List<Map<String, Object>>();
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(strObjectAPIName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.fieldSets.getMap().get(strFieldSetAPIName);
        if (fieldSetObj != null) {
            for (Schema.FieldSetMember fieldSetMemberObj : fieldSetObj.getFields()) {
                listReturnFieldSet.add(new Map<String, Object>{
                        'fieldName' => fieldSetMemberObj.getFieldPath()
                        , 'type' => String.valueOf(fieldSetMemberObj.getType())
                        , 'label' => fieldSetMemberObj.getLabel()
                });
            }
        }
        return listReturnFieldSet;
    }

    /**
     * @description Field Set 에 들어있는 Field API 만 가져올시 사용한다
     * @param strObjectAPIName Object API 명
     * @param strFieldSetAPIName FieldSet 의 API 명
     *
     * @return List<필드 API 명>
     */
    public static List<String> getFieldSetForAPIName(String strObjectAPIName, String strFieldSetAPIName) {
        List<String> listReturnFieldSetApi = new List<String>();
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(strObjectAPIName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.fieldSets.getMap().get(strFieldSetAPIName);

        if (fieldSetObj != null) {
            for (Schema.FieldSetMember fieldSetMemberObj : fieldSetObj.getFields()) {
                listReturnFieldSetApi.add(fieldSetMemberObj.getFieldPath());
            }
        }
        return listReturnFieldSetApi;
    }

    /**
     * @description 오브젝트의 API명과 Label을 매칭
     * @param strObjectName Object API 명
     *
     * @return Map<API 명, Label 명>
     */
    public static Map<String, String> getFieldAPILabel(String strObjectName) {
        // Key: API명, Value: Label명
        Map<String, String> mapResult = new Map<String, String>();

        Schema.SObjectType SObjectType = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldsMap = DescribeSObjectResultObj.fields.getMap();
        for (String fieldName : fieldsMap.keySet()) {
            Schema.SObjectField field = fieldsMap.get(fieldName);
            String fieldLabel = field.getDescribe().getLabel();
            mapResult.put(String.valueOf(field), fieldLabel);
        }

        return mapResult;
    }

    /**
     * @description 오브젝트의 모든 필드를 가져올 때 사용.
     * @param strObjectName Object API 명
     *
     * @return Object의 모든 필드를 구분자 ','로 하여 붙임
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
     * @description Picklist Value를 가져온다
     * @param objectType Object API 명
     * @param selectedField 선택한 Picklist 필드 API 명
     *
     * @return Map<픽리스트 api, 픽리스트 label>
     */
    public static Map<String, String> getPickListValueMap(String objectType, String selectedField) {
        Map<String, String> mapPickList = new Map<String, String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) {
            mapPickList.put(pickListVal.getValue(), pickListVal.getLabel());
        }
        return mapPickList;
    }

    //Get Controlling & Dependency Picklist Values
    public class MyPickListInfo {
        public String validFor;
    }
    public static Map<String, List<String>> getFieldDependencies(String objectName, String controllingField, String dependentField) {
        Map<String, List<String>> controllingInfo = new Map<String, List<String>>();

        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);

        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();

        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();

        for (Schema.PicklistEntry currControllingValue : controllingValues) {
            controllingInfo.put(currControllingValue.getValue(), new List<String>());
        }

        for (Schema.PicklistEntry currDependentValue : dependentValues) {
            String jsonString = JSON.serialize(currDependentValue);

            MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);

            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();

            Integer baseCount = 0;

            for (Integer curr : hexString.getChars()) {
                Integer val = 0;

                if (curr >= 65) {
                    val = curr - 65 + 10;
                } else {
                    val = curr - 48;
                }

                if ((val & 8) == 8) {
                    controllingInfo.get(controllingValues[baseCount + 0].getValue()).add(currDependentValue.getValue());
                }
                if ((val & 4) == 4) {
                    controllingInfo.get(controllingValues[baseCount + 1].getValue()).add(currDependentValue.getValue());
                }
                if ((val & 2) == 2) {
                    controllingInfo.get(controllingValues[baseCount + 2].getValue()).add(currDependentValue.getValue());
                }
                if ((val & 1) == 1) {
                    controllingInfo.get(controllingValues[baseCount + 3].getValue()).add(currDependentValue.getValue());
                }

                baseCount += 4;
            }
        }

        return controllingInfo;
    }

    public static String getTypeX(Object o) {
        if (o == null) return '';              // we can't say much about null
        String result = 'Object';     // if we can't find out anything, we will return 'Object'
        if (o instanceof SObject) return ((SObject) o).getSObjectType().getDescribe().getName() + '';
        if (o instanceof Boolean) return 'Boolean';
        if (o instanceof Id) return 'Id';
        if (o instanceof String) return 'String';
        if (o instanceof Blob) return 'Blob';
        if (o instanceof Date) return 'Date';
        if (o instanceof Datetime) return 'Datetime';
        if (o instanceof Time) return 'Time';
        if (o instanceof Integer) return 'Integer';
        if (o instanceof Long) return 'Long';
        if (o instanceof Decimal) return 'Decimal';
        if (o instanceof Double) return 'Double';
        if (o instanceof List<object>) return 'List';
        try {                                                       // crazy but powerful workaround based on the answer of Arpi Jakab (20217-04-17) on SFSE ==> https://salesforce.stackexchange.com/questions/48019/how-to-get-the-runtime-type-of-an-object-dynamically-for-primitive-data-types-a
            Name a = (Name) o;                                      // INTENTIONALLY force runtime exception like: "Invalid conversion from runtime type Map<Id,List<Account>> to Name"
        } catch (Exception e) {
            result = e.getMessage().substringAfter('from runtime type ').substringBefore(' ');

        }
        return result;
    }
}