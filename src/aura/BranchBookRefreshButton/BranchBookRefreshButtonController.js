({

    fnGetBookExt : function(component, event, helper) {
        helper.getBookExt(component, event, helper);
    },

    fnRefreshBooks : function(component, event, helper) {
        helper.refreshBooks(component, event, helper);
    },

    fnDelBook : function(component, event, helper) {
        helper.delBook(component, event, helper);
    },

	rerun : function(component, event, helper) {
        helper.rerunFailedIF(component, event, helper);
    },

    fnRefreshPrices : function(component, event, helper) {
        helper.refreshPrices(component, event, helper);
    },

    doRefreshBooks : function(component, event, helper) {
        helper.deleteBooks(component, event, helper);
    },

    fnDoManualIf : function(component, event, helper) {
        helper.doManualIf(component, event, helper);
    },

    fnInsertBranchBook : function(component, event, helper) {
        helper.insertBranchBook(component, event, helper);
    },
})