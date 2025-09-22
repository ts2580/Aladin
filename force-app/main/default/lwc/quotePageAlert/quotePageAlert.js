/**
 * Created by HSJ on 25. 3. 28..
 */

import {api, LightningElement} from 'lwc';

import testModal from 'c/testModal'

export default class QuotePageAlert extends LightningElement {

    @api
    recordId;

    async fnOpenOpptyModal(){

        console.log(`%c 나는 quotePageAlert 컴포넌트야`, "color:blue");

        testModal.open({
            size: 'small',
            label: '유리님',
            description: '힘내세요.'
        }).then(item => {
            console.dir(JSON.stringify(item,null,2));
            console.log(`%c then`, "color:blue");
        }).catch(e => {
            console.log(`%c 에러!`, "color:red");
            console.log(`%c catch`, "color:blue");
        });

        console.log(`%c 기달기달`, "color:blue");
    }

}