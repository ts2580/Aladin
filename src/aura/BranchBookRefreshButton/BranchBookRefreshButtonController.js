({
    refreshBooks_1 : function(component, event, helper) {
        
        component.find('notifLib').showToast({
            "variant": "success",
            "header": "재고 갱신",
            "message": "지점별 재고 정보 갱신을 시작합니다.",
            "mode": "dismissible"
        });
        
        let startNum = component.get('v.startNum');
        let endNum = component.get('v.endNum');

        /*  
        Future로 한꺼번에 50개 call을 날리니까 알라딘에서 클린 값들을 던져줌
        (AladinHomePageComponentController.cls의 refreshBook_2 메쏘드 참조)
        Apex에는 안타깝게도 Thread.sleep()이 없음. 따라서 프론트단에서 해결해야함
        setTimeout으로 해결 하자. 
        */

        for(let i=1; i<600; i++){
            setTimeout(function(){
                helper.setBranchBook_1(component, event, helper);
                startNum = endNum;
                endNum = i*2+3
                component.set('v.startNum', startNum);
                component.set('v.endNum', endNum);
            }, 1000*i);
        }

        /*  
        지연시간에 i 안곱하면 모든 setTimeout 함수가 1초 지연 후에 실행됨.
        Helper 부르는 함수 하단의 파라미터 세팅하는거 헬퍼로 빼고 싶은데
        빼면 비동기가 이상하게 작동함...
        */

    },

    

	rerun : function(component, event, helper) {
        helper.rerunFailedIF(component, event, helper);
    },

	refreshPrices : function(component, event, helper) {
        helper.setTotalBranchBookPrice(component, event, helper);
    },

    delete : function(component, event, helper) {
        helper.deleteBooks(component, event, helper);
    },

    doRefreshBooks : function(component, event, helper) {
        helper.deleteBooks(component, event, helper);
    },
})