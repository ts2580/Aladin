/**
 * Created by HSJ on 24. 11. 2..
 */

public with sharing class LoginsbySyneboDTO {

    /**
     * @description - JSON 문자열 가지고 LoginsbySynebo 객체 만들기
     */
    public List<Groups> groups;

    public class Groups {
        public String Name;                     // 그룹명
        public List<Credential> credentials;    // 인증정보
    }

    public class Credential {
        public String Name;                     // org 라벨
        public String SfName;                   // userName
        public String Password;                 // password
        public Type Type;                       // Org Type
    }

    public class Type {
        public String Id;                       // Production/Sandbox
    }

    /**
     * @param json - LoginsbySynebo에서 JSON으로 Export한 문자열
     * @return LoginsbySyneboDTO
     */
    public static LoginsbySyneboDTO getSynebo(String json) {
        return (LoginsbySyneboDTO) System.JSON.deserialize(json, LoginsbySyneboDTO.class);
    }
}