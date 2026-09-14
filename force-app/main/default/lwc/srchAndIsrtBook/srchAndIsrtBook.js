/**
 * Created by SungJin on 25. 9. 25..
 */

import { LightningElement } from "lwc";

import getBooks from "@salesforce/apex/SearchAndInsertBookController.getBooks";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import { dataToExcel } from "c/excelExport";

export default class SrchAndIsrtBook extends LightningElement {
  isSpinnerOpen = false;

  param = {
    bookTitle: "",
    bookTitleExt: ""
  };

  listBook = [];

  listBookExt = [];

  fnSetSpinnerOpen() {
    this.isSpinnerOpen = true;
  }

  fnHideSpinner() {
    this.isSpinnerOpen = false;
  }

  setParam(e) {
    let dataId = e.target.getAttribute("data-id");
    this.param[dataId] = e.target.value;
  }

  async fnExcelExport() {
    this.fnSetSpinnerOpen();

    let listBook = this.listBook.map((item) => {
      return {
        sfid: item.Id,
        제목목목목목목: item.Name,
        분야야야야야야야야야: item.Type__c,
        Cooooooooooooooooooooover: item.Cover__c,
        Seqqqqqqqqqqqqqqqqqqqqqqqqqqq: item.f_Order__c,
        "설명!!!!!!!!!!!!!!!!!!!!!!!!!!!!!": item.Description__c
      };
    });

    if (listBook.length === 0) {
      this.showNotification("", "출력할 데이터가 없습니다.", "error");
    } else {
      await dataToExcel(listBook, "검색 도서 목록", ["분야야야야야야야야야"]);
    }

    this.fnHideSpinner();
  }

  fnEnter(e) {
    if (e.keyCode === 13) this.fnSearch();
  }

  async fnSearch() {
    this.fnSetSpinnerOpen();

    let searchWord = this.param.bookTitle;

    if (!searchWord?.trim()) {
      this.showNotification("", "제목을 입력해주세요", "error");
    } else {
      let arrayBook = await getBooks({ title: searchWord });

      if (arrayBook.length === 0) {
        this.showNotification(
          "",
          "해당 제목의 책이 존재하지 않습니다.",
          "error"
        );
      } else {
        this.showNotification("", "책 정보를 불러왔습니다.", "success");
        this.listBook = arrayBook;
      }
    }

    this.fnHideSpinner();
  }

  fnOpenBookInsertModal() {}

  fnClearBookInt() {}

  fnHandleSuccess() {}

  fnHandleError() {}

  fnDoIf() {}

  fnKeyUp() {}

  fnOpenBookExtInsertModal() {}

  fnShowInsertedBook() {}

  fnClearBookExt() {}

  fnDoIfExt() {}

  fnGoAla() {}

  fnDeleteBook() {}

  fnSetBook() {}

  showNotification(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
      })
    );
  }
}
