({
	fnInit : function(component, event, helper) {

	    component.set('v.bookColumns', [
            { label: '제목', fieldName: 'name__c', type: 'text'},
            { label: '구매여부', fieldName: 'ispurched__c', type: 'boolean'},
            { label: '가격', fieldName: 'price__c', type: 'text'},
            { label: '권', fieldName: 'volume__c', type: 'Number'},
            { label: '표지', fieldName: 'cover__c', type: 'url'},
        ]);


        helper.getBook(component, event, helper);
    }
})