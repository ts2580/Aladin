/**
 * Created by 한성진 on 2023-02-17.
 */

({
    insertBook: function(component, event, helper){

        let objBook = component.get('v.book');
        let action = component.get('c.insertBook');

        action.setParam("paramBook", objBook);

        action.setCallback(this, function(response){

            let state = response.getState();

            if(state === "SUCCESS"){

                this.setToast(component, "success", "새 책이 생성되었습니다.");

                let insertedBook = response.getReturnValue();
                let parentComponent = component.get("v.parent");
                let isInsertAndNew = component.get('v.isInsertAndNew');

                if(isInsertAndNew){
                    // 저장 및 새로만들기 버튼일 시 모달 냅두고 필드만 비워주기
                    component.find('bookField').forEach(
                        function(fnc) {
                            fnc.reset();
                        }
                    );
                }else{
                    parentComponent.fnSetAndCloseModal(insertedBook);
                }
            }else{
                this.setToast(component, "error", "새 책 생성을 실패하였습니다.");
            }
        });

        $A.enqueueAction(action);
    },

    insertBookExt: function(component, event, helper){

        let objBook = component.get('v.bookExt');
        let action = component.get('c.insertBookExt');

        action.setParam("paramBook", objBook);

        action.setCallback(this, function(response){

            let state = response.getState();

            if(state === "SUCCESS"){
                this.setToast(component, "success", "새 책이 생성되었습니다.");

                let insertedBook = response.getReturnValue();
                let parentComponent = component.get("v.parent");
                let isInsertAndNew = component.get('v.isInsertAndNew');

                if(isInsertAndNew){
                    // 저장 및 새로만들기 버튼일 시 모달 냅두고 필드만 비워주기
                    component.find('bookField').forEach(
                        function(fnc) {
                            fnc.reset();
                        }
                    );
                }else{
                    parentComponent.fnSetAndCloseModalExt(insertedBook);
                }
            }else{
                this.setToast(component, "error", "새 책 생성을 실패하였습니다.");
            }
        });

        $A.enqueueAction(action);
    },

    setToast: function (component, variant, message) {
        component.find('notificationLib').showToast({
            'variant' : variant,
            'message' : message,
            'mode'    : 'dismissible'
        });
    },
});