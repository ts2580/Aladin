/**
 * Created by trsty on 26. 1. 2..
 */

import { api, LightningElement } from "lwc";

export default class FlowTable extends LightningElement {
  @api
  arrayTemp4 = [];

  columns = [
    { label: "선행기술조사 이름", fieldName: "Name" },
    { label: "등급", fieldName: "Grade__c" }
  ];

  connectedCallback() {
    if (this.arrayTemp4.length === 0) this.arrayTemp4.push({});
  }

  handleChange(e) {
    try {
      const idx = Number(e.target.dataset.idx);
      const dataId = e.target.getAttribute("data-id");
      this.arrayTemp4[idx][dataId] = e.target.value;
    } catch (error) {
      console.log(
        `%c handleChange error :: ${JSON.stringify(error.message, null, 2)}`,
        "color:red"
      );
    }
  }
}
