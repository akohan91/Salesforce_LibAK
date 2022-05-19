/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
import { LightningElement, api } from 'lwc'
import { showErrorModal } from 'c/lwcUtils'
import { flattenForDataTable } from './sobjectTableUtils'
import init from '@salesforce/apex/SobjectTableCtrl.init'

export default class SobjectTable extends LightningElement {
	@api controllerName = 'default'
	@api sobjectName;
	_selectFields;
	@api get selectFields() {
		return this._selectFields;
	}
	set selectFields(value) {
		try {
			if (value) {
				if (Array.isArray(value)) {
					this._selectFields = value
				} else {
					this._selectFields = value.replace(/[\s]/g, '').split(',');
				}
			}
		} catch (error) {
			showErrorModal(error, this);
		}
	}
	@api conditionBlock = null;
	@api limitRecords = 10;

	records;
	dataTableColumns;
	recordsCount = 0;
	offsetRecords = 0;
	isBusy = true;

	get show() {
		return {
			content: this.records && this.dataTableColumns,
			spinner: !this.records || !this.dataTableColumns || this.isBusy,
		}
	}

	connectedCallback() {
		this.initSobjectTable();
	}

	async initSobjectTable() {
		try {
			this.busy();
			let {
				records,
				dataTableColumns,
				recordsCount,
				referenceFieldPaths,
				addressFieldPaths,
			} = await init({
				controllerName: this.controllerName,
				inputDataJSON: JSON.stringify({
					sobjectName:    this.sobjectName,
					selectFields:   this.selectFields,
					conditionBlock: this.conditionBlock,
					offsetRecords:  this.offsetRecords,
					limitRecords:   this.limitRecords,
				})
			});

			this.records = records.map(record => {
				return flattenForDataTable(record, addressFieldPaths, referenceFieldPaths)
			});
			this.recordsCount = recordsCount;
			this.dataTableColumns = dataTableColumns;
		} catch (error) {
			showErrorModal(error, this);
		} finally {
			this.ready();
		}
	}

	busy = () => (this.isBusy = true);
	ready = () => (this.isBusy = false);

	handlePagination(event) {
		this.offsetRecords = event.detail.offset;
		this.initSobjectTable();
	}
}