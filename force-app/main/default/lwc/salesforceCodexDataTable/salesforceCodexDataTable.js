/**
 * Created by 한성진 on 2022-11-24.
 */

import LightningDatatable from 'lightning/datatable';
import imageTableControl from './template/imageTableControl.html';
import richTextContainer from './template/richTextContainer.html';

export default class SalesforceCodexDataTable extends LightningDatatable  {
    static customTypes = {
        image: {
            template: imageTableControl,
            standardCellLayout:false
        },
        richText: {
            template: richTextContainer,
            standardCellLayout:true,
            typeAttributes: ["status"],
        }
    };
}