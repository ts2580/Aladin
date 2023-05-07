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

    doManualIf : function(component, event, helper) {

        let isFirstTry = component.get("v.isFirstTry");
        let tryNum = component.get("v.tryNum");
        let strNum = component.get("v.startNum");
        let endNum = component.get("v.endNum");

        let action = component.get("c.refreshBookManual");

        action.setParams({
            'isFirstTry': isFirstTry,
            'strNum': strNum,
            'endNum': endNum
        });

        action.setCallback(this, function(response){
            let state = response.getState();

            if(state === "SUCCESS" && component.isValid()){

                this.setToast(component, "success", strNum + "번 Seq 부터 " + endNum + "번 Seq까지 실행 완료");

                strNum = endNum;
                endNum = 30*tryNum;
                tryNum++;

                component.set("v.isFirstTry", false);
                component.set("v.tryNum", tryNum);
                component.set("v.startNum", strNum);
                component.set("v.endNum", endNum);
            }
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