/************************************************************************************
 * File Name   : IF_DRS_SFDC_Account_000.cls
 * Author      : 한성진
 * Date        : 2023.01.13
 * Tester      : IF_DRS_SFDC_Account_000_test.cls
 * Target      :
 * Description : Heroku -> SFDC 회원 Select
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2023.01.13      한성진     	    Create
*************************************************************************************/
@RestResource(UrlMapping='/thisBookIs')
global with sharing class IF_test {

    global class Input {
        public String ISBN13;
    }

    global class Output {
        public String title;
        public String mgssage;
    }



    @HttpPost
    global static Output doPost() {
        RestRequest request = RestContext.request;
        String requestBody = request.requestBody.toString();


        Input inputObj = new Input();
        Output outputObj = new Output();

        inputObj = (Input) JSON.deserialize(requestBody, Input.class);


        List<BookByVolume__x> listBooks = [
                SELECT Id, Name__c, ISBN13__c
                FROM BookByVolume__x
                WHERE ISBN13__c =: inputObj.ISBN13
        ];

        if(listBooks.size() > 0){
            Datetime dt = System.now();

            String tt = String.valueOf(dt.time()).substring(0,2);

            Integer tti = Integer.valueOf(tt);

            if(inputObj.ISBN13.equals('9788958284321')){
                outputObj.mgssage = '아랑님';
            }else if(inputObj.ISBN13.equals('9788997735150')){

                if(tti < 18){
                    outputObj.mgssage = '이 시간만에 끝내다니';
                }else{
                    outputObj.mgssage = '아쉽지만';
                }
            }else{
                outputObj.mgssage = '참 잘했어요';
            }


            outputObj.title = listBooks[0].Name__c;
        }else{
            outputObj.title = '검색결과 없음';
            outputObj.mgssage = '값을 잘 못 넣은것같아요 ㅠㅠ';
        }

        return outputObj;
    }
}