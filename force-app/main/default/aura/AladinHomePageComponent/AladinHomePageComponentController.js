({
	fnInit : function(component, event, helper) {
		helper.getBranchBook(component, event, helper);
	},

	goBranch : function(component, event, helper) {
        let url;

		let branchId = event.getSource().get("v.name");

        url = '/lightning/r/Branch__c/' + branchId + '/view';

		window.open(url);

	},
})