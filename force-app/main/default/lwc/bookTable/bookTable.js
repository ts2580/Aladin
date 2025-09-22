import {LightningElement, wire} from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import bookChannel from '@salesforce/messageChannel/BookChannel__c';

import getBooks from '@salesforce/apex/bookController.getBooks';

const columns = [
    { label: '제목', fieldName: 'Name', type: 'text'},
    { label: '종류', fieldName: 'Type__c', type: 'text'},
    { label: '저자', fieldName: 'Author__c', type: 'text'},
    {
        label: '설명',
        fieldName: 'Description__c',
        type: 'richText',
        initialWidth:400,
        typeAttributes: {
            status: {
                fieldName: "statusValue"
            },
        },
    },
    { label: '표지', fieldName: 'Cover__c', type: 'image'}
];

export default class BookTable extends LightningElement {

    tableData;

    columns = columns;

    @wire(MessageContext)
    messageContext;

    isSpinnerOpen = false;

    pageSize = 5;

    totalRecordsCount = 0;

    totalBook;

    fnHandlePagination(event){
        const start = (event.detail-1) * this.pageSize;
        const end = this.pageSize * event.detail;
        this.tableData = this.totalBook.slice(start, end);
    }

    connectedCallback() {
        this.init();
    }

    async init(){
        this.isSpinnerOpen = true;
        let data = await getBooks();

        let addStatus = data.map((record) => {
            // ... : 전개 연산자. 배열의 요소를 하나하나 전개한 값에 status 값을 추가해서 반환한거임. foreach 문 안써도 됨. 코드 단축!
            // 전개연산자 사용하지 않을시 객체 두개가 반환됨.
            return { ...record, statusValue: "utility:ribbon" };
        });

        this.totalRecordsCount = addStatus.length;

        this.totalBook = addStatus;

        this.tableData = addStatus.slice(0, this.pageSize);
        this.isSpinnerOpen = false;
    }

    fnSelectBook(event){

        const selectedRow = event.detail.selectedRows[0];
        selectedRow['feeling'] = '기분좋음';
        selectedRow['isPurchased'] = true;

        const payLoad = {
            recordId:selectedRow['Id'],
            recordData:selectedRow
        }

        console.dir('Publish함!')
        publish(this.messageContext, bookChannel, payLoad);

    }

}