import {LightningElement, track} from 'lwc';
import {createRecord} from "lightning/uiRecordApi";
import {ShowToastEvent} from "lightning/platformShowToastEvent";

const fields = ["Name", "AccountNumber", "Phone", "RegistrationDate__c"]

const numberFields = ['NumberOfEmployees']

const keyOrder = ["Name", "AccountNumber", "Phone", "NumberOfEmployees","RegistrationDate__c"]

export default class InsertAccount extends LightningElement {

    @track
    mainArray = [];

    connectedCallback() {
        this.mainArray.push(this.setNull());
    }

    setNull(){
        let returnObject = {};

        fields.forEach(field => {
            returnObject[field] = null;
        })

        return returnObject;

    }

    fnAddRow(){
        this.mainArray.push(this.setNull());
    }

    fnDeleteRow(){
        this.mainArray.pop();
    }

    async fnSave(){

        let records = this.mainArray.map(item => {
            let object = {};
            object['apiName'] = 'Account';
            object['fields'] = item;

            return object;
        });

        const recordPromise = records.map(record => {
            createRecord(record)
        })

        Promise.all(recordPromise)
            .then(() => {
                this.fnSetToast('계정생성','만들었음','success');

                setTimeout(()=>{
                    this.fnClose();
                }, 500)
            })
            .catch(error => {
                console.dir(error.message);
            })


    }

    fnGo(){
        window.location.href = "https://daeu-4c-dev-ed.lightning.force.com/lightning/o/Account/list?filterName=AllAccounts";
    }

    fnClose(){
        window.location.href = "https://daeu-4c-dev-ed.lightning.force.com/lightning/o/Account/list?filterName=AllAccounts";
    }

    handlePaste(event){

        // 기본 붙여넣기 동작 방지
        event.preventDefault();

        // 붙여넣은 데이터를 가진 DataTransfer Object를 반환. getData(format)으로 값 꺼내옴
        const clipboardData = event.clipboardData || window.clipboardData;

        // 내가 붙여넣은 값
        const pastedData = clipboardData.getData('Text');

        console.dir(pastedData);
        console.dir('===========================================');

        // 디버그 찍히는것을 보면~ 탭문자(\t)와 줄바꿈 문자(\r\n)가 보인다.
        console.dir(JSON.stringify(pastedData));
        console.dir('===========================================');

        // 데이터의 갯수는 row의 수로 구분이 된다. 줄이 바뀌면~ 다음 데이터이다. 데이터는 우하다능로 흐른다.
        // filter를 사용해서 row가 true일 때 값을 반환 하도록 함.
        const rows = pastedData.split('\n').filter(row => row);

        console.dir(JSON.stringify(rows));
        console.dir('=====================');

        const targetInput = event.target;

        // 시작점 좌표를 알아내는 방법.

        // 시작 행(y축)
        const startIdx = parseInt(targetInput.dataset.index);

        // 시작 컬럼(x축)
        const startKey = targetInput.dataset.key;

        // 데이터와 좌표가 준비되었음. 이제 데이터를 우하단 방향으로 흘려보자.

        rows.forEach((rowData, rowIndex) => {

            // 최대로 붙여 넣을 수 있는 값
            const rowIndexMax = startIdx + rowIndex;

            // 탭문자를 사용해서 하나로 뭉쳐있던 배열 안 요소들을 나눠준다.
            const cells = rowData.split('\t');

            console.dir(JSON.stringify(cells));
            console.dir('=====================');

            // 본 배열의 길이를 넘는 값이 드렁오면 row 추가
            // 배열의 길이 10, 내가 복사한 row는 4, 붙여넣은 셀의 idx는 8
            // 첫 번쨰 rowIndexMax 8 + 0 < 10
            // 두 번쨰 rowIndexMax 8 + 1 < 10
            // 세 번쨰 rowIndexMax 8 + 2 = 10
            // 네 번쨰 rowIndexMax 8 + 3 > 10

            // 행 추가
            if(rowIndexMax >= this.mainArray.length) this.fnAddRow();

            // 배열의 요소를 반복문으로 돌리자
            cells.forEach((cellData, cellIndex) => {

                // column의 순서(keyOrder)가 곧 x좌표임
                const keyIndexMax = keyOrder.indexOf(startKey) + cellIndex;

                // 이번엔 최대 열을 넘는 값은 버린다
                if(keyIndexMax < keyOrder.length){

                    // 붙여넣을 key 구하기. cells.forEach다 돌아 갈수록 우측으로 + 1
                    // 붙여넣은 셀이 Name이면, 맨 처음에 Name 넣어주고, keyIndexMax에 cellIndex를 더해 줌으로써 우측으로 한칸씩 옮기며 데이터 넣어줌
                    const keyToUpdate = keyOrder[keyIndexMax];

                    this.mainArray = this.mainArray.map((item, index) => {

                        if(index === rowIndexMax){
                            return {...item, [keyToUpdate]:this.parseCellData(cellData,keyToUpdate)}
                        }

                        return item;
                    })
                }
            })
        })
    }

    parseCellData(cellData, key){

        // 숫자필드니?
        if(numberFields.includes(key)){
            const parsedValue = parseFloat(cellData)
            return isNaN(parsedValue) ? 0 : parsedValue;
        }

        return cellData.trim();

    }

    /**
     *
     * @param {string} title - 토스트 제목
     * @param {string} message - 토스트 메세지
     * @param {string} variant -형식, error, warning, success
     */
    fnSetToast(title, message, variant){
        dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        )
    };



















}