/**
 * Created by 한성진 on 2023-09-26.
 */

import {LightningElement, api, track, wire} from 'lwc';
import customStyles from '@salesforce/resourceUrl/customCS';
import {loadStyle} from 'lightning/platformResourceLoader';
import getBranchBook from '@salesforce/apex/LwcController.getBranchBook';

const bookColumns =  [
    {
             label: '구매링크',
             fieldName: 'link',
             type: 'url',
             typeAttributes: {
                 label: {
                     fieldName: 'title'
                 },
                 class : 'btn_next'
             }
    },
    /*{
         label: '제목',
         fieldName: 'bookByUrl',
         type: 'url',
         typeAttributes: {
             label: {
                 fieldName: 'title'
             },
             class : 'btn_next'
         }
    },*/
    {
        label: '권',
        fieldName: 'volume',
        type: 'text'
    },
    {
         label: '책',
         fieldName: 'bookUrl',
         type: 'url',
         typeAttributes: {
             label: {
                 fieldName: 'bookName'
             },
             class : 'btn_next'
         }
    },
    {
        label: '가격',
        fieldName: 'price',
        type: 'text'
    }
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

}