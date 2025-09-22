/**
 * Created by trsty on 24. 9. 24..
 */

import {LightningElement, api, wire} from 'lwc';

import { CurrentPageReference } from 'lightning/navigation';

export default class LwcButton extends LightningElement {

    @wire(CurrentPageReference)
    currentPageRef;

    @api
    userNm;

    @api
    accountId;

    @api
    list_accounts;

    connectedCallback() {
        console.dir(this.userNm);
        console.dir(JSON.stringify(this.list_accounts));
    }

    get list_accounts(){
        return this.currentPageRef.state.c__list_accounts;
    }

    get userNm(){
        return this.currentPageRef.state.c__userNm;
    }

    get accountId(){
        return this.currentPageRef.state.c__accountId;
    }



}