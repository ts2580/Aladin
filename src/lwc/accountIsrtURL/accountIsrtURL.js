/**
 * Created by trsty on 24. 9. 24..
 */

import {LightningElement,api,wire} from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class AccountIsrtUrl extends LightningElement {

    @api
    accid;

    @api
    listAccounts;

    @api
    han;

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        if (currentPageReference) {
            const state = currentPageReference.state;
            console.dir(state);
            this.listAccounts = state.c__list_accounts;
            this.han = state.c__han;
            this.accid = state.c__accid;
            console.dir(JSON.stringify(this.listAccounts, null, 2));
            console.dir(JSON.stringify(this.han, null, 2));
            console.dir(JSON.stringify(this.accid, null, 2));
        }
    }
}