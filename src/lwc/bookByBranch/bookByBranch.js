/**
 * Created by 한성진 on 2023-09-26.
 */

import {LightningElement, api, track, wire} from 'lwc';
import customStyles from '@salesforce/resourceUrl/customCS';
import {loadStyle} from 'lightning/platformResourceLoader';
import getBranchBook from '@salesforce/apex/LwcController.getBranchBook';

const bookColumns =  [
    {
         label: '제목',
         fieldName: 'title',
         type: 'text'
    },
    {
        label: '권',
        fieldName: 'volume',
        type: 'Number'
    },
    {
         label: '책',
         fieldName: 'bookUrl',
         type: 'button',
         typeAttributes: {
             label: {
                 fieldName: 'bookName'
             },
             class : 'btn_next',
             onclick: {fnClick}
         }
    },
    {
        label: '가격',
        fieldName: 'price',
        type: 'text'
    },
    {
        label: '구매링크',
        fieldName: 'link',
        type: 'url'
    },
];

export default class BookByBranch extends LightningElement {

    connectedCallback() {
        loadStyle(this, customStyles);
    }

    books = [];

    bookColumns = bookColumns;

    @api
    recordId;

    @track
    error;

    @track
    data;

    @wire(getBranchBook, {recordId : '$recordId'})

    paramBooks({error, data}) {
        if(data){
            console.log(data)
            this.books = data;
        }else if (error){
            this.error = error;
        }
    };

    fnClick(event) {
        console.dir('앙뇽앙뇽');
    };


}