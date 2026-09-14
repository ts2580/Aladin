import { LightningElement, wire, track } from "lwc";
import fieldDeployPipeline from "@salesforce/apex/S4_Util.fieldDeployPipeline";
import getAllObjName from "@salesforce/apex/S4_Util.getAllObjName";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import insertFields from "@salesforce/apex/S4_Util.insertFields";

const fields = [
  "targetObj",
  "type",
  "label",
  "name",
  "description",
  "calculatedFormula",
  "picklistString",
  "referenceString",
  "relationshipName",
  "result"
];

const keyOrder = [
  "targetObj",
  "type",
  "label",
  "name",
  "description",
  "length",
  "precision",
  "scale",
  "visibleLines",
  "calculatedFormula",
  "picklistString",
  "referenceString",
  "relationshipName",
  "result"
];

const numberFields = ["length", "precision", "scale", "visibleLines"];

export default class FieldDeployPipeline extends LightningElement {
  isSpinnerOpen = false;

  objNames = [];

  autoComplete = [];

  totalRecordsCount = 0;

  toolingField = [];

  targetObj = "대기중";

  connectedCallback() {
    this.fnAddRow();
  }

  @wire(getAllObjName)
  setObjNames({ data }) {
    if (data) {
      this.objNames = data;
      this.isSpinnerOpen = false;
    } else {
      this.isSpinnerOpen = true;
    }
  }

  fnExportExcel() {
    try {
      let exportEx = this.toolingField.map((item) => {
        delete item.picklistValues;
        delete item.referenceTo;
        delete item.custom;
        return {
          targetObj: this.targetObj || null,
          type: item.type || null,
          label: item.label || null,
          name: item.name || null,
          description: item.description || null,
          length: item.length || null,
          precision: item.precision || null,
          scale: item.scale || null,
          visibleLines: item.visibleLines || null,
          calculatedFormula: item.calculatedFormula || null,
          picklistString: item.picklistString || null,
          referenceString: item.referenceString || null,
          relationshipName: item.relationshipName || null
        };
      });

      this.template.querySelector("c-cm_-excel-export").excelExport(exportEx);
      this.fnSetToast("", "엑셀 추출 완료", "success");
    } catch (e) {
      console.dir(e.message);
      this.fnSetToast("", "엑셀 추출 실패", "warning");
    }
  }

  fnSetObj(e) {
    let input = e.target.value.toLowerCase();

    if (input) {
      let data = this.objNames;

      let result = [];

      data.forEach((item) => {
        if (item.toLowerCase().includes(input)) result.push(item);
      });

      this.autoComplete = result;
    }
  }

  async setCode(e) {
    try {
      this.isSpinnerOpen = true;

      this.targetObj = e.target.value;

      let toolingField = [];

      await fieldDeployPipeline({ objName: e.target.value })
        .then((returnItem) => {
          // CustomField Toolinig에 POST로 타입 맞춰서 넣어야 하는데
          // 막상 CustomField Toolinig에 Get 요청 날리면 Type을 안줌.
          // describe로 가져온 Type은 CustomField Toolinig에 넣을 Type과 다름.
          // 노가다 시작...

          returnItem.forEach((item) => {
            if (item.calculatedFormula) {
              if (item.type === "double") {
                item.type = "Number";
                item.length = 0;
              } else if (item.type === "string") {
                item.type = "Text";
                item.precision = 0;
                item.scale = 0;
                item.length = 0;
              }
            } else if (
              item.type === "date" ||
              item.type === "phone" ||
              item.type === "url"
            ) {
              if (item.type === "phone") {
                item.type = "Phone";
              } else if (item.type === "url") {
                item.type = "Url";
              } else if (item.type === "date") {
                item.type = "Date";
              }
            } else if (item.type === "datetime") {
              item.type = "DateTime";
            } else if (item.type === "double") {
              item.type = "Number";
            } else if (item.type === "percent") {
              item.type = "Percent";
            } else if (item.type === "Currency") {
              item.type = "Currency";
            } else if (item.type === "string") {
              item.type = "Text";
            } else if (item.type === "textarea") {
              item.type = "LongTextArea";
            } else if (item.type === "reference") {
              item.type = "Lookup";
            } else if (item.type === "boolean") {
              item.type = "Checkbox";
            } else if (item.type === "picklist") {
              item.type = "picklist";
            }

            toolingField.push(item);
          });
        })
        .catch((error) => {
          console.dir(error.message);
        });

      this.toolingField = toolingField;
      this.totalRecordsCount = toolingField.length;
    } catch (error) {
      console.error(error);
    } finally {
      this.isSpinnerOpen = false;
    }
  }

  /* 이하 엑셀 붙여넣는 테이블 코드*/

  @track
  mainArray = [];

  fnAddRow() {
    this.mainArray.push(this.setNull());
  }

  fnDeleteRow() {
    let tempArray = [];
    this.mainArray.forEach((item) => {
      if (!item.check) tempArray.push(item);
    });

    this.mainArray = tempArray;

    this.template
      .querySelectorAll('[data-type="CheckBox"]')
      .forEach((element, idx) => {
        element.checked = false;
        this.mainArray[idx].check = false;
      });
  }

  fnSetCheck(e) {
    const index = e.currentTarget.dataset.index;
    let value = e.currentTarget.checked;

    this.mainArray[index].check = value;
  }

  fnSetCheckAll() {
    let isChecked;

    this.template
      .querySelectorAll('[data-type="CheckBox"]')
      .forEach((element, idx) => {
        isChecked = !element.checked;
        element.checked = isChecked;
        this.mainArray[idx].check = isChecked;
      });
  }

  fnSetData(e) {
    let mainArray = JSON.parse(JSON.stringify(this.mainArray));

    const index = e.currentTarget.dataset.index;
    const value = e.currentTarget.value;
    const key = e.currentTarget.dataset.key;

    mainArray[index][key] = value;

    this.mainArray = mainArray;
  }

  async fnSave() {
    this.isSpinnerOpen = true;

    let returnParam;
    let obj;

    // 한꺼번에 가져올 수도 있는데 기다리는데 시간이 너무 오래걸림.
    // 어짜피 Tooling으로 필드 하나씩 생성하는거니 뺵에 한개씩 갔다오도록 수정
    for (let i = 0; i < this.mainArray.length; i++) {
      this.mainArray[i].result = "작업중...";
      this.mainArray[i].result2 = null;

      // Tooling API 처리 결과를 행별로 보여줘야 해서 순차 저장한다.
      // eslint-disable-next-line no-await-in-loop
      returnParam = await insertFields({
        listField: new Array(this.mainArray[i])
      });

      try {
        obj = JSON.parse(returnParam);
        if (!obj.success) {
          this.mainArray[i].result = obj[0].message;
          this.mainArray[i].result2 = "삽입실패";
        } else {
          this.mainArray[i].result = "삽입성공";
        }
      } catch {
        this.mainArray[i].result = "업데이트 성공";
      }
    }

    this.isSpinnerOpen = false;
  }

  fnClose() {
    this.close();
  }

  setNull() {
    let returnObj = {};

    fields.forEach((field) => {
      returnObj[field] = null;
    });

    return returnObj;
  }

  handlePaste(event) {
    event.preventDefault();

    const clipboardData = event.clipboardData || window.clipboardData;
    const rows = this.getClipboardRows(clipboardData);

    const targetInput = event.target;
    const startIdx = parseInt(targetInput.dataset.index, 10);
    const startKey = targetInput.dataset.key;

    rows.forEach((cells, rowIndex) => {
      const rowIndexMax = startIdx + rowIndex;

      if (rowIndexMax >= this.mainArray.length) this.fnAddRow();

      cells.forEach((cellData, cellIndex) => {
        const keyIndexMax = keyOrder.indexOf(startKey) + cellIndex;

        if (keyIndexMax < keyOrder.length) {
          const keyToUpdate = keyOrder[keyIndexMax];
          this.mainArray = this.mainArray.map((item, index) => {
            if (index === rowIndexMax && item) {
              item.result = null;
              return {
                ...item,
                [keyToUpdate]: this.parseCellData(cellData, keyToUpdate)
              };
            }
            return item;
          });
        }
      });
    });
    this.fnAttach();
  }

  getClipboardRows(clipboardData) {
    const htmlData = clipboardData.getData("text/html");
    const textData = clipboardData.getData("Text");

    if (htmlData) {
      const htmlRows = this.parseHtmlRows(htmlData);
      if (htmlRows.length > 0) return htmlRows;
    }

    return this.parseDelimitedRows(textData);
  }

  parseHtmlRows(htmlData) {
    const documentHtml = new DOMParser().parseFromString(htmlData, "text/html");
    const tableRows = Array.from(documentHtml.querySelectorAll("tr"));

    return tableRows
      .map((row) =>
        Array.from(row.children)
          .filter((cell) => cell.matches("td, th"))
          .map((cell) => cell.innerText)
      )
      .filter((row) => row.length > 0);
  }

  parseDelimitedRows(textData) {
    const rows = [];
    let row = [];
    let cell = "";
    let isQuoted = false;

    for (let i = 0; i < textData.length; i++) {
      const char = textData[i];
      const nextChar = textData[i + 1];

      if (char === '"') {
        if (isQuoted && nextChar === '"') {
          cell += char;
          i++;
        } else {
          isQuoted = !isQuoted;
        }
      } else if (char === "\t" && !isQuoted) {
        row.push(cell);
        cell = "";
      } else if ((char === "\n" || char === "\r") && !isQuoted) {
        row.push(cell);
        if (row.some((value) => value !== "")) rows.push(row);
        row = [];
        cell = "";
        if (char === "\r" && nextChar === "\n") i++;
      } else {
        cell += char;
      }
    }

    if (cell !== "" || row.length > 0) {
      row.push(cell);
      if (row.some((value) => value !== "")) rows.push(row);
    }

    return rows;
  }

  parseCellData(cellData, key) {
    if (numberFields.includes(key)) {
      const parsedValue = parseFloat(cellData);
      return isNaN(parsedValue) ? 0 : parsedValue;
    }
    return cellData.trim();
  }

  fnAttach() {
    this.mainArray = JSON.parse(JSON.stringify(this.mainArray));
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
