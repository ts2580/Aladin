/**
 * Created by 한성진 on 2022-11-24.
 */

import {LightningElement, wire, api} from 'lwc';
// wires the Apex method
import getBook from '@salesforce/apex/AladinHomePageComponentController.getBook';

const bookColumns =  [
    {label: '제목', fieldName: 'Name__c', type: 'text', editable: true},
    {label: '구매여부', fieldName: 'IsPurchased__c', type: 'boolean', editable: true},
    {label: '가격', fieldName: 'Price__c', type: 'text', editable: true},
    {label: '권', fieldName: 'Volume__c', type: 'Number', editable: true},
    {label: '표지', fieldName: 'Cover__c', type: 'image', editable: true},
    {type: 'action', typeAttributes: { rowActions: actions }}
];

const actions = [
    {label: 'Show details', name: 'show_details'},
    {label: 'Delete', name: 'delete'}
];

export default class BookPageLwc extends LightningElement {

    @api
    recordId;

    bookColumns = bookColumns;

    @wire(getBook, {recordId : '$recordId'})
    books;

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'delete':
                this.deleteRow(row);
                break;
            case 'show_details':
                this.showRowDetails(row);
                break;
            default:
        }
    }

    deleteRow(row) {
        const { id } = row;
        const index = this.findRowIndexById(id);
        if (index !== -1) {
            this.data = this.data
                .slice(0, index)
                .concat(this.data.slice(index + 1));
        }
    }

    findRowIndexById(id) {
        let ret = -1;
        this.data.some((row, index) => {
            if (row.id === id) {
                ret = index;
                return true;
            }
            return false;
        });
        return ret;
    }

    showRowDetails(row) {
        this.record = row;
    }

}