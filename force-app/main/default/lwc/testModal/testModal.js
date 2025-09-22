/**
 * Created by HSJ on 25. 3. 28..
 */
import { LightningElement, api, wire } from 'lwc';
import LightningModal from 'lightning/modal';

export default class TestModal extends LightningModal  {

    @api
    recordId;

    connectedCallback() {
        console.log(`%c 나는 OpportunityClosedWin 컴포넌트야`, "color:orange");
    }

}