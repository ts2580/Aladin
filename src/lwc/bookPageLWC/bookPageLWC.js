/**
 * Created by 한성진 on 2022-11-24.
 */

import {LightningElement, wire, api} from 'lwc';
import getBook from '@salesforce/apex/AladinHomePageComponentController.getBook';
// Apex method와 Wire

import {refreshApex} from '@salesforce/apex';
import {updateRecord} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

const bookColumns =  [
    {
         label: '제목',
         fieldName: 'Name__c',
         type: 'button',
         typeAttributes: {
             label: {
                 fieldName: 'Name__c'
             },
             class : 'btn_next'
         }
     },
    {label: '구매여부', fieldName: 'IsPurchased__c', type: 'boolean', editable: true},
    {label: '가격', fieldName: 'Price__c', type: 'text', editable: true},
    {label: '권', fieldName: 'Volume__c', type: 'Number', editable: true},
    {
        label: '표지',
        fieldName: 'Cover__c',
        type: 'image',
        editable: true
    },
];

export default class BookPageLwc extends LightningElement {

    @api
    recordId;

    bookColumns = bookColumns;
    draftValues = [];

    @wire(getBook, {recordId : '$recordId'})
    books;

    async handleSave(event) {
        // 데이타 테이블의 값을 Object로 변환
        const records = event.detail.draftValues.slice().map((draftValue) => {
            const fields = Object.assign({}, draftValue);
            return { fields };
        });

        // 데이타 테이블의 draft값을 날리기
        this.draftValues = [];

        try {
            // UI API 사용해서 레코드 업데이트
            const recordUpdatePromises = records.map((record) =>
                updateRecord(record)
            );
            await Promise.all(recordUpdatePromises);

            // 성공시 토스트
            this.dispatchEvent(
                new ShowToastEvent({
                    title: '수정완료',
                    message: '책 정보 수정을 완료하였습니다',
                    variant: 'success'
                })
            );

            // 비동기로 데이터 갱신
            await refreshApex(this.books);
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: '에러났음',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }
    }
}