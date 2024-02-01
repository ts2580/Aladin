/**
 * Created by 한성진 on 2023-02-16.
 */

({
    searchBook: function(component, event, helper){
        component.set('v.isSpinnerOpen', true);
        let searchWord = event.getSource().get('v.value').trim();

        console.dir(searchWord);

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
                        this.setToast(component, "Warning", "검색 결과가 없습니다.");
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
                        this.setToast(component, "Warning", "검색 결과가 없습니다.");
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

        component.set('v.isSpinnerOpen', true);

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
                this.setToast(component, "success", "책 정보 받아오기 성공.");

                let responseBooks = action.getReturnValue();
                
                component.set('v.listBook', responseBooks);
                component.set('v.isBookInsertModalOpen', false);
                component.set('v.isSpinnerOpen', false);

            }
        })
        $A.enqueueAction(action);
    },

    showInsertedBook: function(component, event, helper){

        component.set('v.isSpinnerOpen', true);

        let action = component.get('c.getLatestBook');

        action.setCallback(this, function(response){
            let state = response.getState();

            if(state === 'SUCCESS'){
                this.setToast(component, "success", "책 정보 받아오기 성공.");

                let responseBooks = action.getReturnValue();

                component.set('v.listBookExt', responseBooks);
                component.set('v.isSpinnerOpen', false);
            }
        })
        $A.enqueueAction(action);
    },

    doIfExt: function(component, event, helper){

        component.set('v.isSpinnerOpen', true);

        let objBook = event.getSource().get('v.value');
        let action = component.get('c.getBookExtInfo');

        action.setParams({
            'objBook': objBook
        });

        action.setCallback(this, function(response){
            let state = response.getState();

            if(state === 'SUCCESS'){
                this.setToast(component, "success", "책 정보 받아오기 성공.");

                let responseBooks = action.getReturnValue();
                
                component.set('v.listBookExt', responseBooks);
                component.set('v.isBookInsertModalOpen', false);
                component.set('v.isSpinnerOpen', false);
            }
        })
        $A.enqueueAction(action);
    },

    deleteBook: function(component, event, helper){

        component.set('v.isSpinnerOpen', true);

        let bookId = event.getSource().get('v.value');
        let action = component.get('c.deleteBookExt');

        action.setParams({
            'bookId': bookId
        });

        action.setCallback(this, function(response){
            let state = response.getState();

            if(state === 'SUCCESS'){
                this.setToast(component, "success", "책 삭제 성공.");
            }else{
                this.setToast(component, "error", "책 삭제 실패.");
            }
            component.set('v.isSpinnerOpen', false);
        })
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