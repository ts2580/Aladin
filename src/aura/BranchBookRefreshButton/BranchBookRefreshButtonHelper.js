({
    setBranchBook_1 : function(component, event, helper){

        component.set('v.isSpinnerOpen', true);

        let action = component.get("c.refreshBook_1");

        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS" && component.isValid()){
                this.setToast(component, "success", "지점별 재고 정보를 갱신하였습니다.");
            }
            component.set('v.isSpinnerOpen', false);
        });

        $A.enqueueAction(action);

    },

    setBranchBook_2 : function(component, event, helper){

        let action = component.get("c.refreshBook_2");

        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS" && component.isValid()){
                this.setToast(component, "success", "지점별 재고 정보 2를 갱신중입니다.");
            }
        });

        $A.enqueueAction(action);
    },

    setBranchBook_3 : function(component, event, helper){

        let action = component.get("c.refreshBook_3");

        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS" && component.isValid()){
                this.setToast(component, "success", "지점별 재고 정보 3을 갱신중입니다.");
            }
        });

        $A.enqueueAction(action);
    },

    rerunFailedIF : function(component, event, helper){

        component.set('v.isSpinnerOpen', true);

        let action = component.get("c.rerunFailedIF");

        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS" && component.isValid()){
                this.setToast(component, "success", "실패한 인터페이스를 재실행하였습니다.");
            }
            component.set('v.isSpinnerOpen', false);
        });

        $A.enqueueAction(action);
    },

    setTotalBranchBookPrice : function(component, event, helper){

        component.set('v.isSpinnerOpen', true);

        let action = component.get("c.refreshPrice");

        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS" && component.isValid()){
                this.setToast(component, "success", "지점별 재고 총액 정보를 갱신하였습니다.");
            }
            component.set('v.isSpinnerOpen', false);
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