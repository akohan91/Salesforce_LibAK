/**
 * @author Andrei Kakhanouski <akohan91@gmail.com>
 */
import { LightningElement, api } from 'lwc'
import { showErrorModal } from 'c/lwcUtils'
import { DynamicSOQLOrderBy } from 'c/soql'
import { flattenForDataTable, overrideDataTableColumns } from './sobjectTableUtils'
import init from '@salesforce/apex/SobjectTableCtrl.init'

export default class SobjectTable extends LightningElement {
	@api controllerName;
	@api sobjectName;
	@api get selectFields() { return this._selectFields; }
	set selectFields(value) {
		try {
			if (value) {
				this._selectFields = Array.isArray(value) ? value : value.replace(/[\s]/g, '').split(',');
			}
		} catch (error) {
			showErrorModal(error, this);
		}
	}
	@api conditionBlock = null;
	@api limitRecords = 10;
	@api sortedBy;
	@api sortedDirection;
	@api columnsToOverride;
	@api hideCheckboxColumn = false;
	@api selectedRows;

	_selectFields;
	recordsCount = 0;
	offsetRecords = 0;
	records;
	dataTableColumns;
	isBusy = true;

	get show() {
		try {
			return {
				content: this.records && this.dataTableColumns,
				spinner: !this.records || !this.dataTableColumns || this.isBusy,
			}
		} catch (error) {
			showErrorModal(error, this);
		}
	}

	get orderBy() {
		try {
			return this.sortedBy &&
				new DynamicSOQLOrderBy([this.sortedBy], this.sortedDirection === 'desc') ||
				null;
		} catch (error) {
			showErrorModal(error, this);
		}
	}

	@api refresh() {
		this.initSobjectTable();
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
					orderBy:        this.orderBy,
					offsetRecords:  this.offsetRecords,
					limitRecords:   this.limitRecords,
				})
			});

			this.records = records.map(record => flattenForDataTable(record, addressFieldPaths, referenceFieldPaths));
			this.recordsCount = recordsCount;
			this.dataTableColumns = overrideDataTableColumns(dataTableColumns, this.columnsToOverride);
			this.dispatchEvent(new CustomEvent('recordsloaded', { detail: this.records }));
		} catch (error) {
			showErrorModal(error, this);
		} finally {
			this.ready();
		}
	}

	busy = () => (this.isBusy = true);
	ready = () => (this.isBusy = false);

	handlePagination(event) {
		try {
			this.offsetRecords = event.detail.offset;
			this.initSobjectTable();
		} catch (error) {
			showErrorModal(error, this);
		}
	}

	handleSort(event) {
		try {
			this.sortedBy = event.detail.columnKey;
			this.sortedDirection = event.detail.sortDirection;
			this.initSobjectTable();
		} catch (error) {
			showErrorModal(error, this);
		}
	}

	handleRowAction(event) {
		try {
			this.dispatchEvent(new CustomEvent('rowaction', { detail: {...event.detail} }))
		} catch (error) {
			showErrorModal(error, this);
		}
	}

	handleRowSelection(event) {
		try {
			this.dispatchEvent(new CustomEvent('rowselection', { detail: {...event.detail} }))
		} catch (error) {
			showErrorModal(error, this);
		}
	}
}