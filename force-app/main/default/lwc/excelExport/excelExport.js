/**
 * Created by SungJin on 2025-09-22.
 */
import {loadScript} from "lightning/platformResourceLoader";
import exceljs from '@salesforce/resourceUrl/excelJS';

async function dataToExcel(downloadData, fileName, centerNames) {
    if (downloadData.length > 0) {
        try{
            await loadScript(this, exceljs);                            // Exceljs 라이브러리 load

            // WorkBook를 생성. exceljs 스크립트를 loadScript 하면 ExcelJS라는 전역 변수가 생김
            // new exceljs.Workbook(); 이게 아님. 여기서 또 헤멨네 ㅡㅡ
            const workbook = new ExcelJS.Workbook();
            const worksheet = workbook.addWorksheet('Sheet 1');         // 시트를 생성

            // 헤더스타일지정
            const headerStyle = {
                type: 'pattern',
                pattern: 'solid',
                fgColor: { argb: 'D2DAE5' },
            }

            // Border 스타일지정
            const borderStyle = {
                left: { style: 'thin', color: { argb: 'rgba(173, 216, 230, 0.8)' } },
                right: { style: 'thin', color: { argb: 'rgba(173, 216, 230, 0.8)' } },
                top: { style: 'thin', color: { argb: 'rgba(173, 216, 230, 0.8)' } },
                bottom: { style: 'thin', color: { argb: 'rgba(173, 216, 230, 0.8)' } }
            }

            // 1) 컬럼 정의
            const headers = Object.keys(downloadData[0] ?? {});
            const columns = headers.map(h => ({ name: h }));

            // 첫 번째 테이블 시작 위치
            const table1StartRow = 1;
            const table1Ref = 'A' + table1StartRow;

            worksheet.addTable({
                name: 'Table1',
                ref: table1Ref,            // 예: 'A1'
                headerRow: true,
                columns,
                rows: downloadData.map(row => Object.values(row)),
            });

            // 헤더명 -> 컬럼번호 매핑
            const headerRowNo = table1StartRow;
            const nameToIndex = {};
            worksheet.getRow(headerRowNo).values.forEach((v, cIdx) => {
                if (v) nameToIndex[String(v).trim()] = cIdx;
            });

            // 셀 단위로 정렬 적용 (헤더 포함/제외 선택)
            const centerCols = [...centerNames].map(n => nameToIndex[n]).filter(Boolean);
            const table1RowCount = downloadData.length; // 데이터 행 수

            // 2) 폭 계산 유틸
            const colLabelToIndex = (label) => {
                let n = 0;
                for (let i = 0; i < label.length; i++) n = n * 26 + (label.charCodeAt(i) - 64);
                return n; // 'A'-> 1
            };

            // 컬럼 헤더 값을 통해 인덱스부터 뽑아오자
            const startCol = colLabelToIndex(table1Ref.replace(/\d+/g, '')); // A1 -> A -> 1

            const widthByHeader = (s) => {
                let sum = 0;
                for (const ch of String(s)) {
                    const code = ch.codePointAt(0);
                    if (code >= 0xAC00 && code <= 0xD7A3) sum += 2;        // 한글
                    else if ((code >= 65 && code <= 90)
                        || (code >= 97 && code <= 122)) sum += 1.1;        // 영문 A-Z a-z
                    else if (code >= 48 && code <= 57) sum += 1;           // 0-9
                    else if (ch === ' ') sum += 0.6;                       // 공백 약간 작게 잡음
                    else sum += 1;                                         // 기타 특문. 너무 광범위해. 걍 1로 잡아
                }

                const pad = 2;
                const w = Math.ceil(sum) + pad;
                return Math.max(8, Math.min(60, w));
            };

            // 3) 컬럼 폭 적용
            headers.forEach((h, i) => {
                const col = worksheet.getColumn(startCol + i);
                col.width = widthByHeader(h);
            });

            // 스타일 입혀주기
            applyStyles(table1StartRow, Object.keys(downloadData[0]).length, downloadData.length, headerStyle, borderStyle, worksheet);

            // 헤더까지 포함하면 headerRowNo부터
            centerCols.forEach(ci => {
                for (let r = headerRowNo; r <= headerRowNo + table1RowCount; r++) {
                    worksheet.getCell(r, ci).alignment = { horizontal: 'center', vertical: 'middle' };
                }
            });

            // 엑셀다운로드 witerBuffer
            workbook.xlsx.writeBuffer().then(function(buffer) {
                const blob = new Blob([buffer], { type: "application/octet-stream" });
                const url = URL.createObjectURL(blob);

                const a = document.createElement("a");
                a.href = url;
                a.download = fileName+'.xlsx';
                a.click();
                URL.revokeObjectURL(url);
            });
        }catch(e){
            console.log(`%c ExcelDn Error :: ${e.message}`, "color:red");
        }
    }

    function applyStyles(startRow, columnCount, rowCount, headerStyle, borderStyle, worksheet) {
        for (let i = 1; i <= columnCount; i++) {
            const headerCell = worksheet.getCell(`${getExcelColumnName(i)}${startRow}`);
            headerCell.fill = headerStyle;
            headerCell.border = borderStyle;
            headerCell.alignment = { horizontal: 'center' };
            headerCell.font = { bold: true };
        }

        // 데이터 셀 스타일 지정
        for (let rowIndex = startRow + 1; rowIndex <= startRow + rowCount; rowIndex++) {
            const row = worksheet.getRow(rowIndex);
            row.eachCell({ includeEmpty: true }, (cell) => {
                cell.border = borderStyle;
                cell.alignment = { vertical: 'middle' };

                if (typeof cell.value === 'string' && cell.value.match(/^[\d,.\-]+$/)) {
                    const numeric = Number(cell.value.replace(/,/g, ''));
                    if (!isNaN(numeric)) {
                        cell.numFmt = /\./.test(cell.value) ? '#,##0.########' : '#,##0';
                        cell.value = numeric;
                    }
                }
            });
        }
    }

    //엑셀다운로드시 헤더Cell의 행번을 생성하는 로직 A ~ Z / AA ~ AZ / BA ~ BZ ....
    function getExcelColumnName(index) {
        let columnName = '';
        while (index > 0) {
            index--;
            columnName = String.fromCharCode(65+(index % 26) ) + columnName;
            index = Math.floor(index / 26);
        }
        return columnName;
    }
}

export {dataToExcel}