({
    deleteBooks : function(component, event, helper){
        let action = component.get("c.deleteBook");

        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS" && component.isValid()){
                component.find('notifLib').showToast({
                    "variant": "success",
                    "header": "재고 삭재",
                    "message": "지점별 재고를 삭제하였습니다.",
                    "mode": "dismissible"
                });
            }
        });

        $A.enqueueAction(action);
    },

    setBranchBook_1 : function(component, event, helper){

        let startNum = component.get('v.startNum');
        let endNum = component.get('v.endNum');

        let action = component.get("c.refreshBook_1");
        action.setParams({
            "startNum": startNum,
            "endNum": endNum
        });

        action.setCallback(this, function(response){
            let state = response.getState();
            console.dir(startNum + ' ~ ' + endNum);
        });

        $A.enqueueAction(action);
    },

    setBranchBook_2 : function(component, event, helper){

        let action = component.get("c.refreshBook_2");

        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS" && component.isValid()){
                component.find('notifLib').showToast({
                    "variant": "success",
                    "header": "재고 갱신",
                    "message": "지점별 재고 정보 2를 갱신중입니다.",
                    "mode": "dismissible"
                });
            }
        });

        $A.enqueueAction(action);
    },

    setBranchBook_3 : function(component, event, helper){

        let action = component.get("c.refreshBook_3");

        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS" && component.isValid()){
                component.find('notifLib').showToast({
                    "variant": "success",
                    "header": "재고 갱신",
                    "message": "지점별 재고 정보3을 갱신중입니다.",
                    "mode": "dismissible"
                });
            }
        });

        $A.enqueueAction(action);
    },

    rerunFailedIF : function(component, event, helper){

        let action = component.get("c.rerunFailedIF");

        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS" && component.isValid()){
                component.find('notifLib').showToast({
                    "variant": "success",
                    "header": "재실행",
                    "message": "실패한 인터페이스를 재실행합니다.",
                    "mode": "dismissible"
                });
            }
        });

        $A.enqueueAction(action);
    },

    setTotalBranchBookPrice : function(component, event, helper){
        let action = component.get("c.refreshPrice");
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS" && component.isValid()){
                component.find('notifLib').showToast({
                    "variant": "success",
                    "header": "재고 갱신",
                    "message": "지점별 재고 총액 정보를 갱신중입니다.",
                    "mode": "dismissible"
                });
            }
        });
        $A.enqueueAction(action);
    }
});