({
    setBranchBook_1 : function(component, event, helper){
        var action = component.get("c.refreshBook_1");

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS" && component.isValid()){
                component.find('notifLib').showNotice({
                    "variant": "success",
                    "header": "재고 갱신",
                    "message": "지점별 재고 정보를 갱신중입니다.",
                    "mode": "dismissible"
                });
            }
        });

        $A.enqueueAction(action);
    },

    setBranchBook_2 : function(component, event, helper){

        var action = component.get("c.refreshBook_2");

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS" && component.isValid()){
                component.find('notifLib').showNotice({
                    "variant": "success",
                    "header": "재고 갱신",
                    "message": "지점별 재고 정보를 갱신중입니다.",
                    "mode": "dismissible"
                });
            }
        });

        $A.enqueueAction(action);
    },

    rerunFailedIF : function(component, event, helper){

        var action = component.get("c.rerunFailedIF");

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS" && component.isValid()){
                component.find('notifLib').showNotice({
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
        var action = component.get("c.refreshPrice");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS" && component.isValid()){
                component.find('notifLib').showNotice({
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