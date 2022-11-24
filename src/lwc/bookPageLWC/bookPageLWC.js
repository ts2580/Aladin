/**
 * Created by 한성진 on 2022-11-24.
 */

import { LightningElement, wire, api } from 'lwc';
// wires the Apex method
import getBook from '@salesforce/apex/AladinHomePageComponentController.getBook';

const bookColumns =  [
    { label: '제목', fieldName: 'name__c', type: 'text'},
    { label: '구매여부', fieldName: 'ispurched__c', type: 'boolean'},
    { label: '가격', fieldName: 'price__c', type: 'text'},
    { label: '권', fieldName: 'volume__c', type: 'Number'},
    { label: '표지', fieldName: 'cover__c', type: 'url'},
];

export default class BookPageLwc extends LightningElement {

    @api recordId;
    bookColumns = bookColumns;

    @wire(getBook, {recordId : '$recordId'})
    books;
}