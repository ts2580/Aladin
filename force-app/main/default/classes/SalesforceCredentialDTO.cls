/**
 * Created by HSJ on 24. 11. 2..
 */

public with sharing class SalesforceCredentialDTO {

    public class Credential {
        public String name;                 // org 라벨
        public String group2;               // 그룹명
        public String username;             // userName
        public String password;             // password
        public String environmentType;      // login/test
        public String color;                // #00A1E0 세일즈포스 디폴트 퍼렁색
        public String uiType;               // 1:classic, 2/lightning
    }

    public static List<Credential> getCredentials(String json){
       return (List<Credential>) System.JSON.deserialize(json, List<Credential>.class);
    }

    public static String transSyneboToCredential(String json){

        List<Credential> listCre = new List<Credential>();
        Credential cre;

        for (LoginsbySyneboDTO.Groups groups : LoginsbySyneboDTO.getSynebo(json).groups) {

            for (LoginsbySyneboDTO.Credential credential : groups.credentials) {
                cre = new Credential();
                cre.group2 = groups.Name;
                cre.name = credential.Name;
                cre.username = credential.SfName;
                cre.password = credential.Password;
                cre.environmentType = credential.Type.Id == 'Production' ? 'login' : 'test';
                cre.color = '#00A1E0';
                cre.uiType = '2';
                listCre.add(cre);
            }
        }

        return System.JSON.serializePretty(listCre).replaceAll('"group2" :', '"group" :');
    }
}