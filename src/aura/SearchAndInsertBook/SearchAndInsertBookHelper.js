/**
 * Created by 한성진 on 2023-02-16.
 */

({
    searchBook: function(component, event, helper){
        component.set('v.isSpinnerOpen', true);
        let searchWord = event.getSource().get('v.value').trim();

        if(searchWord){
            let action = component.get('c.getBooks');

            action.setParams({
                'title': searchWord
            });

            action.setCallback(this, function(response){
                let state = response.getState();

                if(state === 'SUCCESS'){
                    let responseBooks = action.getReturnValue();

                    if(responseBooks.length == 0){
                        let setToast = component.get('c.setToast');

                        let toastMap = new Map();
                        toastMap.set('variant', 'Warning');
                        toastMap.set('message', '검색 결과가 없습니다.');

                        component.set('v.toastMap', toastMap);
                        $A.enqueueAction(setToast);
                    }else{
                        component.set('v.listBook', responseBooks);
                    }
                    component.set('v.isSpinnerOpen', false);
                }
            })
            $A.enqueueAction(action);
        }

    },

    searchBookExt: function(component, event, helper){
        component.set('v.isSpinnerOpen', true);
        let searchWord = event.getSource().get('v.value').trim();

        if(searchWord){
            let action = component.get('c.getBookExt');

            action.setParams({
                'title': searchWord
            });

            action.setCallback(this, function(response){
                let state = response.getState();

                if(state === 'SUCCESS'){
                    let responseBooks = action.getReturnValue();

                    if(responseBooks.length == 0){
                        let setToast = component.get('c.setToast');

                        let toastMap = new Map();
                        toastMap.set('variant', 'Warning');
                        toastMap.set('message', '검색 결과가 없습니다.');

                        component.set('v.toastMap', toastMap);
                        $A.enqueueAction(setToast);
                    }else{
                        component.set('v.listBookExt', responseBooks);
                    }
                    component.set('v.isSpinnerOpen', false);
                }
            })
            $A.enqueueAction(action);
        }

    },

    doIf: function(component, event, helper){

        // Autonumber는 childComponent에서 파라미터로 오브젝트 넘길때 안들어옴. 오토넘버 생성시 시간이 좀 걸리는것으로 판단됨.
        // IF_GetBookInfo의 IF 메소드의 매개변수를 Name 필드로 변경함
        let title = event.getSource().get('v.value').trim();
        let action = component.get('c.getBookInfo');

        action.setParams({
            'title': title
        });

        action.setCallback(this, function(response){
            let state = response.getState();

            if(state === 'SUCCESS'){
                let setToast = component.get('c.setToast');

                let toastMap = new Map();
                toastMap.set('variant', 'success');
                toastMap.set('message', '책 정보 받아오기 성공.');

                component.set('v.toastMap', toastMap);
                $A.enqueueAction(setToast);

                let responseBooks = action.getReturnValue();
                
                component.set('v.listBook', responseBooks);
                component.set('v.isBookInsertModalOpen', false);

            }
        })
        $A.enqueueAction(action);
    },

    doIfExt: function(component, event, helper){

        let title = event.getSource().get('v.value').trim();
        let action = component.get('c.getBookExtInfo');

        action.setParams({
            'title': title
        });

        action.setCallback(this, function(response){
            let state = response.getState();

            if(state === 'SUCCESS'){
                let setToast = component.get('c.setToast');

                let toastMap = new Map();
                toastMap.set('variant', 'success');
                toastMap.set('message', '책 정보 받아오기 성공.');

                component.set('v.toastMap', toastMap);
                $A.enqueueAction(setToast);

                let responseBooks = action.getReturnValue();
                
                component.set('v.listBookExt', responseBooks);
                component.set('v.isBookInsertModalOpen', false);
            }
        })
        $A.enqueueAction(action);
    },

    deleteBook: function(component, event, helper){
        let bookId = event.getSource().get('v.value');

        let action = component.get('c.deleteBookExt');

        action.setParams({
            'bookId': bookId
        });

        action.setCallback(this, function(response){
            let state = response.getState();
            let setToast = component.get('c.setToast');
            let toastMap = new Map();

            if(state === 'SUCCESS'){
                
                toastMap.set('variant', 'success');
                toastMap.set('message', '책 삭제 성공.');

                component.set('v.toastMap', toastMap);
            }else{
                toastMap.set('variant', 'error');
                toastMap.set('message', '책 삭제 실패.');
                component.set('v.toastMap', toastMap);
                
            }
            $A.enqueueAction(setToast);
        })
        $A.enqueueAction(action);
    },

    setAndCloseModal: function(component, event, helper){
        let result = event.getParam('arguments');
        let objBook = result.paramBook;

        let listBook = new Array();
        listBook.push(objBook);

        component.set('v.listBook', listBook);
        component.set('v.isBookInsertModalOpen', false);
    },

    setAndCloseModalExt: function(component, event, helper){
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
    
});