/**
 * Created by 한성진 on 2023-02-16.
 */

({
    fnHandleSuccess: function (component, event, helper) {
       helper.setToast(component, "success", "책 정보 수정 성공.");
    },

    fnHandleError: function (component, event, helper) {
        helper.setToast(component, "error", "책 정보 수정 실패.");
    },

    fnSearchBook: function(component, event, helper){
        helper.searchBook(component, event, helper);
    },

    fnClearBookInt: function(component, event, helper){
        let emptyArray = [];
        component.set('v.listBook', emptyArray);
    },

    fnClearBookExt: function(component, event, helper){
        let emptyArray = [];
        component.set('v.listBookExt', emptyArray);
    },

    fnShowInsertedBook: function(component, event, helper){
        let emptyArray = [];
        component.set('v.listBookExt', emptyArray);
        helper.showInsertedBook(component, event, helper);
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

    fnGoAla: function(component, event, helper){
        let link = event.getSource().get('v.value');

        window.open(link);
    },

    fnSetAndCloseModal: function(component, event, helper){
        let result = event.getParam('arguments');
        let objBook = result.paramBook;

        let listBook = new Array();
        listBook.push(objBook);

        component.set('v.listBook', listBook);
        component.set('v.isBookInsertModalOpen', false);
    },

    fnSetAndCloseModalExt: function(component, event, helper){
        let result = event.getParam('arguments');
        let objBook = result.paramBookExt;

        let listBookExt = new Array();
        listBookExt.push(objBook);

        // External Object에 넣는건 Async로 들어가기땜에 Id값을 못 가져옴.
        // 이 경우 recordEditForm에 Id 세팅이 무의미하단 소리
        // inputField에 따로 value 설정 해줌. 짜피 If 날릴떈 Name으로 하니깐 뭐
        component.set('v.listBookExt', listBookExt);
        component.set('v.isBookInsertModalOpen', false);
    },

    fnSearchBookExt: function(component, event, helper){
        helper.searchBookExt(component, event, helper);
    },

    fnSetBook: function(component, event, helper){
        helper.setBook(component, event, helper);
    },

});