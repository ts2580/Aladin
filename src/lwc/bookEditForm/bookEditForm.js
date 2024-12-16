import {LightningElement, wire} from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import bookChannel from '@salesforce/messageChannel/BookChannel__c';

export default class BookEditForm extends LightningElement {

    @wire(MessageContext)
    messageContext;

    recordData = {};

    recordId;

    connectedCallback() {
        this.sub();
    }

    sub(){
        if(!this.subscription){
            this.subscription = subscribe(
                this.messageContext,
                bookChannel,
                (message) => {
                    console.dir('EditFrom 구독');

                    let obj = JSON.parse(JSON.stringify(message));

                    try {
                        obj['recordData']['feeling'] = '졸림';
                        obj['recordData']['yuri'] = '생일이었음';

                        console.dir(JSON.stringify(obj,null,2));
                    } catch (e) {
                        console.dir(e.body.message);
                    }


                    this.recordId = message.recordId;
                    this.recordData = message.recordData;
                }
            )
        }
    }

}