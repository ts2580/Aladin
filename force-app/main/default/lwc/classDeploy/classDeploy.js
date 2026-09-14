/**
 * Created by sungjin on 25. 3. 10..
 */

import { LightningElement, track, wire } from "lwc";

import getClass from "@salesforce/apex/S4_Util.getClass";
import getLwc from "@salesforce/apex/S4_Util.getLwc";
import getAura from "@salesforce/apex/S4_Util.getAura";
import getVF from "@salesforce/apex/S4_Util.getVF";
import getTrigger from "@salesforce/apex/S4_Util.getTrigger";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class ClassDeploy extends LightningElement {
  @track
  originalArray = {
    apexClass: [],
    apexTestClass: [],
    lwc: [],
    aura: [],
    vf: [],
    trigger: []
  };

  @track
  autoComplete = {
    apexClass: new Set(),
    apexTestClass: new Set(),
    lwc: new Set(),
    aura: new Set(),
    vf: new Set(),
    trigger: new Set()
  };

  @track
  deployArray = {
    apexClass: new Set(),
    apexTestClass: new Set(),
    lwc: new Set(),
    aura: new Set(),
    vf: new Set(),
    trigger: new Set()
  };

  prodAlias = "";

  isSpinnerOpen = false;

  @track
  deployCode;

  apexView = true;
  apexTestView = false;
  LwcView = false;
  auraView = false;
  vfView = false;
  triggerView = false;

  @wire(getClass, {})
  getClass({ error, data }) {
    if (data) {
      // 네이밀룰을 안지킨 사람들이 너무 많다
      data.forEach((item) => {
        // this.originalArray.apexTestClass.push(item);
        // this.originalArray.apexClass.push(item);

        if (item.includes("_test") || item.includes("_Test")) {
          this.originalArray.apexTestClass.push(item);
        } else {
          this.originalArray.apexClass.push(item);
        }
      });
    } else {
      console.dir(JSON.stringify(error, null, 2));
    }
  }

  @wire(getLwc, {})
  getLwc({ error, data }) {
    if (data) {
      this.originalArray.lwc = data;
    } else {
      console.dir(JSON.stringify(error, null, 2));
    }
  }

  @wire(getAura, {})
  getAura({ error, data }) {
    if (data) {
      this.originalArray.aura = data;
    } else {
      console.dir(JSON.stringify(error, null, 2));
    }
  }

  @wire(getVF, {})
  getVF({ error, data }) {
    if (data) {
      this.originalArray.vf = data;
    } else {
      console.dir(JSON.stringify(error, null, 2));
    }
  }

  @wire(getTrigger, {})
  getTrigger({ error, data }) {
    if (data) {
      this.originalArray.trigger = data;
    } else {
      console.dir(JSON.stringify(error, null, 2));
    }
  }

  strictMode = false;

  connectedCallback() {}

  renderedCallback() {
    const buttons = this.template.querySelectorAll(".setDeployTarget");

    buttons.forEach((btn) => {
      if (!btn.dataset.bound) {
        // 우클릭 이벤트는 contextmenu로 감지
        btn.addEventListener("contextmenu", this.handleContextMenu.bind(this));
        btn.dataset.bound = "true"; // 중복 방지
      }
    });
  }

  handleCheck(event) {
    this.strictMode = event.target.checked; // true / false
  }

  handleContextMenu(event) {
    event.preventDefault(); // 우클릭 메뉴 차단

    const dataId = event.target.getAttribute("data-id");
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

      this.apexView = value === "APEX";
      this.apexTestView = value === "APEX_TEST";
      this.LwcView = value === "LWC";
      this.auraView = value === "AURA";
      this.vfView = value === "VF";
      this.triggerView = value === "TRIGGER";
    } catch (error) {
      console.log(
        `%c error :: ${JSON.stringify(error.body, null, 2)}`,
        "color:red"
      );
    }
  }

  get listMetadata() {
    return [
      {
        label: "APEX Class",
        value: "APEX",
        description: "APEX Class"
      },
      {
        label: "APEX Test Class",
        value: "APEX_TEST",
        description: "APEX Test Class"
      },
      {
        label: "APEX Trigger",
        value: "TRIGGER",
        description: "Apex Trigger"
      },
      {
        label: "LWC",
        value: "LWC",
        description: "Lightning Web Component"
      },
      {
        label: "AURA",
        value: "AURA",
        description: "AURA Component"
      },
      {
        label: "VF",
        value: "VF",
        description: "VisualForce"
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

  get auraAutoCompleteList() {
    return [...this.autoComplete.aura];
  }

  get vfAutoCompleteList() {
    return [...this.autoComplete.vf];
  }

  get triggerAutoCompleteList() {
    return [...this.autoComplete.trigger];
  }

  fnSetClass(e) {
    try {
      let input = e.target.value;

      const dataId = e.target.getAttribute("data-id");

      let result = new Set();

      if (input.trim().length !== 0) {
        let returnArray = [];

        // 탭 쪼개기
        let rows = input.split("\t");

        rows.forEach((item) => {
          // 줄바꿈문자 Array로 만들고 요소 하나씩 꺼내서 push
          item.split(" ").forEach((item2) => {
            if (item2.trim().length !== 0) returnArray.push(item2);
          });
        });

        const data = this.originalArray[dataId];

        returnArray.forEach((item) => {
          data.forEach((item2) => {
            if (this.strictMode) {
              if (item2.toUpperCase() === item.toUpperCase()) result.add(item2);
            } else {
              if (item2.toUpperCase().includes(item.toUpperCase()))
                result.add(item2);
            }
          });
        });
      }

      this.autoComplete[dataId] = result;
    } catch (error) {
      console.dir("error :: " + JSON.stringify(error.body, null, 2));
    }
  }

  setCode(e) {
    let input = e.target.value;
    const dataId = e.target.getAttribute("data-id");

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
      set.delete(item); // 값이 있으면 제거
    } else {
      set.add(item); // 값이 없으면 추가
    }
    return set;
  }

  makeCliCode() {
    let alias = this.prodAlias.split(",").map((s) => s.trim());

    let baseCode = "";
    let code = "";

    let deployTestArray = new Set(this.deployArray.apexTestClass);
    let deployArray = new Set(this.deployArray.apexClass);
    let deployLWC = new Set(this.deployArray.lwc);
    let deployAura = new Set(this.deployArray.aura);
    let deployVF = new Set(this.deployArray.vf);
    let deployTrigger = new Set(this.deployArray.trigger);

    // 중복 제거된 전체 클래스들로 구성. 나는 전개 연산자가 좋아
    let deployApexClass = [
      ...[...deployLWC].map((item) => ` LightningComponentBundle:${item}`),
      ...[...deployAura].map((item) => ` AuraDefinitionBundle:${item}`),
      ...[...deployVF].map((item) => ` ApexPage:${item}`),
      ...[...deployTrigger].map((item) => ` ApexTrigger:${item}`),
      ...[...deployArray].map((item) => ` ApexClass:${item}`),
      ...[...deployTestArray].map((item) => ` ApexClass:${item}`),
      ...[...deployTestArray].map((item) => ` --tests ${item}`)
    ].join(" ");

    baseCode = "sf project deploy start --metadata " + deployApexClass;

    alias.forEach((item) => {
      code +=
        baseCode +
        (!deployTestArray.size
          ? ` --target-org ${item} \n`
          : ` --test-level RunSpecifiedTests --target-org ${item} \n`);
    });

    this.deployCode = code;
  }

  setProdAlias(e) {
    this.prodAlias = e.target.value;
    this.makeCliCode();
  }

  fnCopy() {
    if (!this.prodAlias) {
      this.fnSetToast(
        "별칭 공백",
        "CLI에 등록된 org 별칭을 기입해주세요",
        "warning"
      );
      return;
    }

    navigator.clipboard.writeText(this.deployCode).then(() => {
      this.fnSetToast(
        "배포 코드 복사 완료",
        "CMD 창에 붙여 넣어주세요",
        "success"
      );
    });
  }

  setAddAll(e) {
    const dataId = e.target.getAttribute("data-id");

    this.deployArray[dataId] = new Set([
      ...this.deployArray[dataId],
      ...this.autoComplete[dataId]
    ]);

    this.makeCliCode();
  }

  delAttribute(e) {
    const dataId = e.target.getAttribute("data-id");

    if (dataId === "clearAll") {
      for (const key of Object.keys(this.deployArray)) {
        this.deployArray[key] = new Set();
      }
    } else {
      this.deployArray[dataId] = new Set();
    }

    this.makeCliCode();
  }

  fnXmlCopy() {
    const apexMembersSet = new Set([
      ...this.deployArray.apexClass,
      ...this.deployArray.apexTestClass
    ]);
    const apexMembers = Array.from(apexMembersSet);

    let xml = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n`;
    xml += `<Package xmlns="http://soap.sforce.com/2006/04/metadata">\n`;

    if (apexMembers.length > 0) {
      xml += `    <types>\n`;
      apexMembers.forEach((member) => {
        xml += `        <members>${member}</members>\n`;
      });
      xml += `        <name>ApexClass</name>\n`;
      xml += `    </types>\n`;
    }

    if (this.deployArray.trigger.size > 0) {
      xml += `    <types>\n`;
      this.deployArray.trigger.forEach((member) => {
        xml += `        <members>${member}</members>\n`;
      });
      xml += `        <name>ApexTrigger</name>\n`;
      xml += `    </types>\n`;
    }

    if (this.deployArray.lwc.size > 0) {
      xml += `    <types>\n`;
      this.deployArray.lwc.forEach((member) => {
        xml += `        <members>${member}</members>\n`;
      });
      xml += `        <name>LightningComponentBundle</name>\n`;
      xml += `    </types>\n`;
    }

    if (this.deployArray.aura.size > 0) {
      xml += `    <types>\n`;
      this.deployArray.aura.forEach((member) => {
        xml += `        <members>${member}</members>\n`;
      });
      xml += `        <name>AuraDefinitionBundle</name>\n`;
      xml += `    </types>\n`;
    }

    if (this.deployArray.vf.size > 0) {
      xml += `    <types>\n`;
      this.deployArray.vf.forEach((member) => {
        xml += `        <members>${member}</members>\n`;
      });
      xml += `        <name>ApexPage</name>\n`;
      xml += `    </types>\n`;
    }

    xml += `    <version>65.0</version>\n`;
    xml += `</Package>`;

    navigator.clipboard.writeText(xml).then(() => {
      this.fnSetToast(
        "Package.xml 코드 복사 완료",
        "편하게 써 편하게",
        "success"
      );
    });
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
