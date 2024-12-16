import {api, LightningElement} from 'lwc';

export default class RichTextControl extends LightningElement {
    @api
    richText;

    @api
    typeAttributes = {};
}