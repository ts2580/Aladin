/**
 * Created by 한성진 on 2023-02-17.
 */

({
    fnInit: function(component, event, helper){
        let param = event.getParam('arguments');
        let mode = param.modalMode;

        component.set('v.mode', mode);
    },

    fnCloseModal: function(component, event, helper){
        let fnCloseModal = component.get('v.parent');
        fnCloseModal.fnCloseBookModal();
    },

    fnSetBook: function(component, event, helper){
        helper.setBook(component, event, helper);
    },

    fnInsertBook: function(component, event, helper){
        component.set('v.isInsertAndNew', false);
        helper.insertBook(component, event, helper);
    },

    fnInsertBookAndNew: function(component, event, helper){
        component.set('v.isInsertAndNew', true);
        helper.insertBook(component, event, helper);
    },

    fnInsertBookExt: function(component, event, helper){
        component.set('v.isInsertAndNew', false);
        helper.insertBookExt(component, event, helper);
    },

    fnInsertBookExtAndNew: function(component, event, helper){
        component.set('v.isInsertAndNew', true);
        helper.insertBookExt(component, event, helper);
    },

});