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

    getBookExt : function(component, event, helper){

        component.set('v.isSpinnerOpen', true);

        let action = component.get("c.getBooKAll");

        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS" && component.isValid()){

                let responseBooks = action.getReturnValue();

                console.dir(responseBooks);

                if(responseBooks.length == 0){
                    this.setToast(component, "error", "Heroku 에러.");
                    return;
                }

                component.set('v.BookExt', responseBooks);
                this.setToast(component, "success", "구매대상 책을 모두 불러왔습니다.");
            }else{
                this.setToast(component, "error", "Heroku 에러.");
            }
            component.set('v.isSpinnerOpen', false);
        });

        $A.enqueueAction(action);

    },

    doManualIf : function(component, event, helper) {

        // 재고 검색 대상 권수
        let bookExt = component.get("v.BookExt");

        // 지점별 책 재고
        let branchBookExt = component.get("v.BranchBookExt");

        let isFirstTry = component.get("v.isFirstTry");
        let tryNum = component.get("v.tryNum");
        let strNum = component.get("v.startNum");
        let endNum = component.get("v.endNum");

        let action = component.get("c.refreshBookManual");

        action.setParams({
            'listBooks': bookExt,
            'isFirstTry': isFirstTry,
            'strNum': strNum,
            'endNum': endNum
        });

        action.setCallback(this, function(response){
            let state = response.getState();

            if(state === "SUCCESS" && component.isValid()){

                let responseBooks = action.getReturnValue();

                responseBooks.forEach(function(item){
                    branchBookExt.push(item);
                })

                console.dir(branchBookExt);

                this.setToast(component, "success", strNum + "번 Seq 부터 " + endNum + "번 Seq까지 실행 완료");

                strNum = endNum;
                endNum = 30*tryNum;
                tryNum++;

                component.set("v.isFirstTry", false);
                component.set("v.tryNum", tryNum);
                component.set("v.startNum", strNum);
                component.set("v.endNum", endNum);

                component.set('v.BranchBookExt', branchBookExt);
            }
        });

        $A.enqueueAction(action);
    },

    insertBranchBook : function(component, event, helper){

        component.set('v.isSpinnerOpen', true);

        let action = component.get("c.insertBranchBook");

        let branchBookExt = component.get("v.BranchBookExt");

        action.setParam('listBranchBookExt', branchBookExt);

        // todo 쪼개서 넣는 방식도 생각. 넣은다음 리스트 비우면 됨

        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS" && component.isValid()){
                let consequence = action.getReturnValue();
                if(consequence == 1){
                    this.setToast(component, "success", "재고 저장 성공.");

                    component.set("v.BranchBookExt", branchBookExt.splice(0,0));
                }else{
                    this.setToast(component, "error", "재고 저장 실패.");
                }
            }else{
                this.setToast(component, "error", "Heroku 에러.");
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