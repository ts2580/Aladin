({
    setBranchBook : function(component, event, helper){

        var action = component.get("c.refreshBook");

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

    setTotalBranchBookPrice : function(component, event, helper){
        var action = component.get("c.refreshPrice");

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
    }
});