({
	getBook : function(component, event, helper){
        let action = component.get("c.getBook");

        action.setParams({
            "recordId" : component.get("v.recordId")
        });

        action.setCallback(this, function(response){
            let state = response.getState();

            if(state === "SUCCESS" && component.isValid()){

                component.set('v.listBook', response.getReturnValue());

            }
        });

        $A.enqueueAction(action);
    },
})