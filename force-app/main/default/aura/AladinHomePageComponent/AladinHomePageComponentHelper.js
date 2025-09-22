({
	getBranchBook : function(component, event, helper){
        let action = component.get("c.getBranch");

        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS" && component.isValid()){

                let listBranch = response.getReturnValue();
                component.set('v.listBranch', listBranch);

            }
        });
        $A.enqueueAction(action);
    },

})