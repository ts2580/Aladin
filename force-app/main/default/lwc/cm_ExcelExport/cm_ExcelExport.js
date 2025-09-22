/**
 * Created by yr.Lee on 2024-06-20.
 */

import { LightningElement, api } from 'lwc';
import SheetJS from '@salesforce/resourceUrl/SheetJS';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import {NavigationMixin} from "lightning/navigation";
import getExportData from '@salesforce/apex/CM_ExcelExportController.getExportData';
import getExportDataAll from '@salesforce/apex/CM_ExcelExportController.getExportDataAll';

export default class CmExcelExport extends NavigationMixin(LightningElement) {
    /** 스피너 */
    isSpinnerOpen = false;
    /** List View 에서 받아온 데이터 */
    @api listSelectedId;
    /** Object API 명 */
    @api strObjectAPI;
    /** 다운로드 할 데이터 */
    downloadData;
    /** 전체 추출시 쿼리 */
    @api strQueryAfterFROM;

    async connectedCallback() {
        console.log(this.listSelectedId);

        console.dir('lwc');

        // 해당 컴포넌트를 하위로 가지는 컴포넌트가 있을 경우 엑셀 다운로드 바로 실행하지 않도록 선택된 아이디가 있을 경우로 조건 추가
        if(!this.listSelectedId){

            this.downloadData = await getExportDataAll({strQueryAfterFROM : this.strQueryAfterFROM, strObjectAPI : this.strObjectAPI});
            await this.excelExport(this.downloadData)
                .then(() => {
                    this.handleListViewNavigation();
                });
        }else{
            // 자바스크립트에서 false로 반환되는 값은 "", null, undefined, 0, NaN
            // if (this.listSelectedId != undefined && this.listSelectedId.length > 0) <- 이정도로 쓸 필요는 없음
            this.downloadData = await getExportData({listSelectedIds : this.listSelectedId, strObjectAPI : this.strObjectAPI});
            await this.excelExport(this.downloadData)
                .then(() => {
                    this.handleListViewNavigation();
                });
        }
    }

    // 타 컴포넌트에서도 사용가능하도록 @api 추가, 파라미터로 다운로드 할 데이터를 받아옴
    @api
    async excelExport(downloadData){
        console.log('[LWC] excelExport 시작 :: ');
        // console.dir(JSON.stringify(downloadData, null, 2));
        console.log(new Date());
        this.isSpinnerOpen = true;

        if (downloadData.length > 0) {
            await loadScript(this, SheetJS); // SheetJS 라이브러리 load
            // 해당 라이브러리는 XLSX로 접근 가능
            this.version = XLSX.version;

            let currentdate = new Date();
            // 현재 날짜로 파일 명 설정
            const filename = '( ' + currentdate.getFullYear() + '-' + (currentdate.getMonth() + 1) + '-' + currentdate.getDate() + ' ) ExportToExcel.xlsx';
            const workbook = XLSX.utils.book_new();
            const headers = [];
            const worksheetData = downloadData;

            const worksheet = XLSX.utils.json_to_sheet(worksheetData, { header: headers });
            XLSX.utils.book_append_sheet(workbook, worksheet, 'ExportToExcel');

            const excelBuffer = XLSX.write(workbook, { bookType: 'xlsx', type: 'array' });
            const blob = new Blob([excelBuffer], { type: 'application/octet-stream' });

            // 다운로드 링크 생성
            const a = document.createElement('a');
            a.href = URL.createObjectURL(blob);
            a.download = filename;
            a.click();
            URL.revokeObjectURL(a.href);
        }
        console.log('[LWC] excelExport 끝 :: ');
        console.log(new Date());

        this.isSpinnerOpen = false;
    };

    // ListView 페이지로 이동
    handleListViewNavigation() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: this.strObjectAPI,
                actionName: 'home'
            }
        });
    }
}