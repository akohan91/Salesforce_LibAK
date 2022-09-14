import { LightningElement, api } from 'lwc';

import { showErrorModal } from 'c/lwcUtils'

import search from '@salesforce/apex/SobjectLookupCtrl.search';

import CreateNewRecord from '@salesforce/label/c.CreateNewRecord';

const DELAY = 300;
const LIST_BOX_OPTION_CSS = 'slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_term';
const COMBOBOX_CSS = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
const FAKE_ID = '000000000000000000';

export default class SobjectLookup extends LightningElement {
	@api controllerName = 'default';
	@api sobjectName;
	@api searchedByFields = ['Name'];
	@api titleFieldName = 'Name';
	@api defaultConditionBlock = null;
	@api limitRecords = 5;
	@api fieldConfig = {
		label: '',
		variant: 'label-hidden',
		placeholder: '',
		iconName: ''
	}

	searchTerm = '';
	offsetRecords = 0;
	searchResult = {
		records: [],
		recordsCount: 0
	}
	isLoading = false;
	show = {
		searchResults: false,
	}
	delayTimeout;
	get comboboxCssClass() {
		return COMBOBOX_CSS + (this.show.searchResults ? ' slds-is-open' : '');
	}

	handleInputFocus() {
		this.search();
	}

	handleInputChange(event) {
		try {
			this.searchTerm = event.target.value;
			clearTimeout(this.delayTimeout);
			this.delayTimeout = setTimeout(() => this.search(), DELAY);
		} catch (error) {
			showErrorModal(error, this);
		}
	}

	handleItemClick(event) {
		try {
			const itemId = event.currentTarget.getAttribute("data-id");
			this.searchResult.records = this.searchResult.records.map(record => ({
				...record,
				hasFocus: record.id === itemId
			}));
			this.sendEvent();
		} catch (error) {
			showErrorModal(error, this);
		}
	}

	handleKeyDown(event) {
		try {
			const {keyCode} = event;
			switch (keyCode) {
				// ESC key
				case 27: this.hideSearchResults(); break;
				// UP key
				case 38: this.setFocusItem(-1); break;
				// DOWN key
				case 40: this.setFocusItem(+1); break;
				// LEFT key
				case 37: this.template.querySelector('.list-pagination').handlePrev(); break;
				// RIGHT key
				case 39: this.template.querySelector('.list-pagination').handleNext(); break;
				// ENTER key
				case 13: this.sendEvent(); break;
			}
		} catch (error) {
			showErrorModal(error, this);
		}
	}

	handlePagination(event) {
		try {
			if (this.offsetRecords === event.detail.offset) {
				return;
			}
			this.offsetRecords = event.detail.offset;
			this.search();
		} catch (error) {
			showErrorModal(error, this);
		}
	}

	search() {
		this.busy();
		search({
			controllerName: this.controllerName || 'default',
			inputJSON: JSON.stringify({
				sobjectName: this.sobjectName,
				searchedByFields: this.searchedByFields,
				searchTerm: this.searchTerm,
				titleFieldName: this.titleFieldName,
				defaultConditionBlock: this.defaultConditionBlock,
				limitRecords: this.limitRecords,
				offsetRecords: this.offsetRecords
			})
		}).then(result => {
			this.searchResult = {
				records: this.buildResultList(result.records),
				recordsCount: result.recordsCount
			}
			this.showSearchResults();
		}).catch(error => {
			showErrorModal(error, this);
		}).finally(() => {
			this.free();
		})
	}

	buildResultList(records) {
		try {
			const comboboxLineAddRecord = { Id: null }
			comboboxLineAddRecord[this.titleFieldName] = CreateNewRecord;
			return [...records, comboboxLineAddRecord].map(record => ({
				record: record,
				id: record.Id || FAKE_ID,
				title: record[this.titleFieldName],
				hasFocus: false,
				get listBoxCssClass() {
					return LIST_BOX_OPTION_CSS + (this.hasFocus ? ' slds-has-focus' : '');
				}
			}));
		} catch (error) {
			showErrorModal(error, this);
		}
	}

	setFocusItem(increment) {
		try {
			let indexToSetFocus;
			let lastItemIndex = this.searchResult.records.length - 1;
			let hasFocusItemIndex = this.searchResult.records.findIndex(record => record.hasFocus);
			if (hasFocusItemIndex === -1) {
				indexToSetFocus = increment === 1 ? 0 : lastItemIndex;
			} else {
				indexToSetFocus = hasFocusItemIndex + increment;
				(indexToSetFocus > lastItemIndex) && (indexToSetFocus = 0);
				(indexToSetFocus < 0) && (indexToSetFocus = lastItemIndex);
				this.searchResult.records[hasFocusItemIndex].hasFocus = false;
			}
			this.searchResult.records[indexToSetFocus].hasFocus = true;
			this.searchResult = {...this.searchResult}
		} catch (error) {
			showErrorModal(error, this);
		}
	}

	sendEvent() {
		try {
			const hasFocusItem = this.searchResult.records.find(record => record.hasFocus);
			if (!hasFocusItem) {
				return;
			}
			let eventToDispatch;
			if (hasFocusItem.id === FAKE_ID) {
				eventToDispatch = new CustomEvent(
					'createnew', {
						detail: {inputValue: this.searchTerm}
					}
				);
			} else {
				eventToDispatch = new CustomEvent(
					'selected', {
						detail: hasFocusItem.record
					}
				);
				this.searchTerm = hasFocusItem.record[this.titleFieldName];
			}
			this.hideSearchResults();
			this.dispatchEvent(eventToDispatch);
		} catch (error) {
			showErrorModal(error, this);
		}
	}

	busy() {
		this.isLoading = true;
	}
	free() {
		this.isLoading = false;
	}
	showSearchResults() {
		this.show = {
			...this.show,
			searchResults: true
		}
	}
	hideSearchResults() {
		this.show = {
			...this.show,
			searchResults: false
		}
		this.searchResult = {
			records: [],
			recordsCount: 0
		}
		this.offsetRecords = 0;
	}
}