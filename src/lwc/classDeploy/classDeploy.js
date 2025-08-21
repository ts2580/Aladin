/**
 * Created by sungjin on 25. 3. 10..
 */

import {LightningElement, track, wire} from 'lwc';

import getClass from '@salesforce/apex/S4_Util.getClass'
import getLwc from '@salesforce/apex/S4_Util.getLwc'
import {ShowToastEvent} from "lightning/platformShowToastEvent";

export default class ClassDeploy extends LightningElement {

    @track
    originalArray = {
        apexClass : [],
        apexTestClass : [],
        lwc : [],
    }

    @track
    autoComplete = {
        apexClass : new Set(),
        apexTestClass : new Set(),
        lwc : new Set(),
    }

    @track
    deployArray = {
        apexClass : new Set(),
        apexTestClass : new Set(),
        lwc : new Set(),
    }

    prodAlias = '';

    isSpinnerOpen = false;

    deployCode;

    apexView = true;
    apexTestView = false;
    LwcView = false;

    @wire(getClass,{})
    getClass({error, data}){
        if(data){
            data.forEach(item => {
                if(item.includes('_test') || item.includes('_Test')){
                    this.originalArray.apexTestClass.push(item);
                }else{
                    this.originalArray.apexClass.push(item);
                }
            })

        }else{
            console.dir(JSON.stringify(error,null,2));
        }
    }

    @wire(getLwc,{})
    getLwc({error, data}){
        if(data){
            this.originalArray.lwc = data;
        }else{
            console.dir(JSON.stringify(error,null,2));
        }
    }

    connectedCallback() {

    }

    renderedCallback() {
        const buttons = this.template.querySelectorAll('.setDeployTarget');

        buttons.forEach(btn => {
            if (!btn.dataset.bound) {
                // 우클릭 이벤트는 contextmenu로 감지
                btn.addEventListener('contextmenu', this.handleContextMenu.bind(this));
                btn.dataset.bound = 'true'; // 중복 방지
            }
        });
    }

    handleContextMenu(event) {
        event.preventDefault(); // 우클릭 메뉴 차단

        const dataId = event.target.getAttribute('data-id');
        const input = event.target.value;

        this.fnDelToggleSetItem(dataId, input);
    }

    fnDelToggleSetItem(dataId, input) {

        let targets = this.autoComplete[dataId];

        if (targets.has(input)) {
            targets.delete(input);

            this.autoComplete[dataId] = new Set([...targets]);
        }
    }

    fnSetMetadata(e) {

        try {
            const value = e.detail.value;

            this.apexView = value === 'APEX';
            this.apexTestView = value === 'APEX_TEST';
            this.LwcView = value === 'LWC';
        } catch (e) {
            console.log(`%c error :: ${JSON.stringify(e.body, null, 2)}`, "color:red");
        }
    }

    get listMetadata() {
        return [
            {
                label: 'APEX Class',
                value: 'APEX',
                description: 'APEX Class',
            },
            {
                label: 'APEX Test Class',
                value: 'APEX_TEST',
                description: 'APEX Test Class',
            },
            {
                label: 'LWC',
                value: 'LWC',
                description: 'Lightning Web Component',
            }
        ];
    }

    get apexAutoCompleteList() {
        return [...this.autoComplete.apexClass];
    }

    get apexTestAutoCompleteList() {
        return [...this.autoComplete.apexTestClass];
    }

    get lwcAutoCompleteList() {
        return [...this.autoComplete.lwc];
    }



    fnSetClass(e) {

        try {
            let input = e.target.value;

            const dataId = e.target.getAttribute('data-id');

            let result = new Set();

            if (input.trim().length !== 0) {
                let returnArray = [];

                // 탭 쪼개기
                let rows = input.split('\t');

                rows.forEach((item) => {
                    // 줄바꿈문자 Array로 만들고 요소 하나씩 꺼내서 push
                    item.split(' ').forEach(item2 => {
                        if (item2.trim().length !== 0) returnArray.push(item2);
                    })
                });

                const data = this.originalArray[dataId];

                returnArray.forEach(item => {
                    data.forEach(item2 => {
                        if(item2.toUpperCase().includes(item.toUpperCase())) result.add(item2);
                    })
                })
            }

            this.autoComplete[dataId] = result;

        } catch (e) {
            console.dir('error :: ' + JSON.stringify(e.body, null, 2));
        }
    }

    setCode(e) {
        let input = e.target.value;
        const dataId = e.target.getAttribute('data-id');

        let data = this.deployArray[dataId];

        try {
            this.isSpinnerOpen = true;

            this.deployArray[dataId] = this.toggleSetItem(data, input);

            this.makeCliCode();
        } catch (error) {
            console.error(error);
        } finally {
            this.isSpinnerOpen = false;
        }
    }

    toggleSetItem(set, item) {
        if (set.has(item)) {
            set.delete(item);  // 값이 있으면 제거
        } else {
            set.add(item);     // 값이 없으면 추가
        }
        return set;
    }

    makeCliCode(){

        let code;

        let deployTestArray = new Set(this.deployArray.apexTestClass);
        let deployArray = new Set(this.deployArray.apexClass);
        let deployLWC = new Set(this.deployArray.lwc);

        // 중복 제거된 전체 클래스들로 구성. 나는 전개 연산자가 좋아
        let deployApexClass = [
            ...[...deployLWC].map(item => ` LightningComponentBundle:${item}`),
            ...[...deployArray].map(item => ` ApexClass:${item}`),
            ...[...deployTestArray].map(item => ` ApexClass:${item}`),
            ...[...deployTestArray].map(item => ` --tests ${item}`)
        ].join(' ');

        code = 'sf project deploy start --metadata ' + deployApexClass;

        code += !deployTestArray.size
            ? ` --target-org ${this.prodAlias} `
            : ` --test-level RunSpecifiedTests --target-org ${this.prodAlias} `;

        this.deployCode = code;

    }

    setProdAlias(e){
        this.prodAlias = e.target.value;
        this.makeCliCode();
    }

    fnCopy(){

        if(!this.prodAlias){
            this.fnSetToast('별칭 공백','CLI에 등록된 org 별칭을 기입해주세요','warning')
            return;
        }

        navigator.clipboard.writeText(this.deployCode)
            .then(() => {
                    this.fnSetToast('배포 코드 복사 완료','CMD 창에 붙여 넣어주세요','success')
                }
            );
    }

    setAddAll(e){
        const dataId = e.target.getAttribute('data-id');

        this.deployArray[dataId] = new Set([...this.deployArray[dataId], ...this.autoComplete[dataId]]);

        this.makeCliCode();
    }

    delAttribute(e){
        const dataId = e.target.getAttribute('data-id');
        
        if(dataId === 'clearAll'){
            for(let key in this.deployArray) this.deployArray[key] = new Set();
        }else{
            this.deployArray[dataId] = new Set();
        }

        this.makeCliCode();
    }

    fnXmlCopy(){
        const apexMembersSet = new Set([...this.deployArray.apexClass, ...this.deployArray.apexTestClass]);
        const apexMembers = Array.from(apexMembersSet);

        let xml = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n`;
        xml += `<Package xmlns="http://soap.sforce.com/2006/04/metadata">\n`;
        if(apexMembers.length > 0){
            xml += `    <types>\n`;
            apexMembers.forEach(member => {
                xml += `        <members>${member}</members>\n`;
            });
            xml += `        <name>ApexClass</name>\n`;
            xml += `    </types>\n`;
        }
        if(this.deployArray.lwc.size > 0){
            xml += `    <types>\n`;
            this.deployArray.lwc.forEach(member => {
                xml += `        <members>${member}</members>\n`;
            });
            xml += `        <name>LightningComponentBundle</name>\n`;
            xml += `    </types>\n`;
        }

        xml += `    <version>64.0</version>\n`;
        xml += `</Package>`;

        navigator.clipboard.writeText(xml)
            .then(() => {
                    this.fnSetToast('Package.xml 코드 복사 완료','편하게 써 편하게','success')
                }
            );
    }


    fnSetToast(title, message, variant) {
        dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }



}
