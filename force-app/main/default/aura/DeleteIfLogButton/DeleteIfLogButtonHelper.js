/**
 * Created by 한성진 on 2023-03-24.
 */

({
    deleteIf : function(component, event, helper) {
        component.set('v.isSpinnerOpen', true);

        let action = component.get("c.deleteIfLog");

        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS" && component.isValid()){
                this.setToast(component, "success", "인터페이스 로그를 삭제하였습니다.");
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