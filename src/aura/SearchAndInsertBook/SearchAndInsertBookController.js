/**
 * Created by 한성진 on 2023-02-16.
 */

({
    fnHandleSuccess: function (component, event, helper) {
        let setToast = component.get('c.setToast');

        let toastMap = new Map();
        toastMap.set('variant', 'success');
        toastMap.set('message', '책 정보 수정 성공.');

        component.set('v.toastMap', toastMap);
        $A.enqueueAction(setToast);
    },

    fnHandleError: function (component, event, helper) {
        let setToast = component.get('c.setToast');

        let toastMap = new Map();
        toastMap.set('variant', 'error');
        toastMap.set('message', '책 정보 수정 실패.');

        component.set('v.toastMap', toastMap);
        $A.enqueueAction(setToast);
    },

    fnSearchBook: function(component, event, helper){
        helper.searchBook(component, event, helper);
    },

    fnDoIf: function(component, event, helper){
        helper.doIf(component, event, helper);
    },

    fnDoIfExt: function(component, event, helper){
        helper.doIfExt(component, event, helper);
    },

    fnDeleteBook: function(component, event, helper){
        helper.deleteBook(component, event, helper);
    },

    fnOpenBookInsertModal: function(component, event, helper){
        component.set('v.isBookInsertModalOpen', true);
        let mode = component.find('setMode');
        mode.setModalMode('int');
    },

    fnOpenBookExtInsertModal: function(component, event, helper){
        component.set('v.isBookInsertModalOpen', true);
        let mode = component.find('setMode');
        mode.setModalMode('ext');
    },

    fnCloseBookModal: function(component, event, helper){
        component.set('v.isBookInsertModalOpen', false);
    },

    fnSetAndCloseModal: function(component, event, helper){
        helper.setAndCloseModal(component, event, helper);
    },

    fnSetAndCloseModalExt: function(component, event, helper){
        helper.setAndCloseModalExt(component, event, helper);
    },

    fnSearchBookExt: function(component, event, helper){
        helper.searchBookExt(component, event, helper);
    },

    setToast: function (component, event, helper) {
        let toastMap = component.get('v.toastMap');
        component.find('notificationLib').showToast({
            'variant' : toastMap.get('variant'),
            'message' : toastMap.get('message'),
            'mode'    : 'dismissible'
        });
    },
});