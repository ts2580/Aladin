import {LightningElement, wire} from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import bookChannel from '@salesforce/messageChannel/BookChannel__c';

export default class BookPath extends LightningElement {

    @wire(MessageContext)
    messageContext;

    currentValue = '1';

    subscription;

    connectedCallback() {
        this.sub();
    }

    sub(){
        if(!this.subscription){
            this.subscription = subscribe(
                this.messageContext,
                bookChannel,
                (message) => {
                    console.dir('Path 구독');
                    this.currentValue = '2';
                }
            )
        }
    }


}