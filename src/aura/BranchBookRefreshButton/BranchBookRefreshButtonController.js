({
    refreshBooks_1 : function(component, event, helper) {
        helper.setBranchBook_1(component, event, helper);
    },

	refreshBooks_2 : function(component, event, helper) {
		helper.setBranchBook_2(component, event, helper);
	},

	rerun : function(component, event, helper) {
        helper.rerunFailedIF(component, event, helper);
    },

	refreshPrices : function(component, event, helper) {
        helper.setTotalBranchBookPrice(component, event, helper);
    },
})