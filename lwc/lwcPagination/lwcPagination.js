/**
 * @author Andrei Kakhanouski <akohan91@gmail.com>
 */
import { LightningElement,api } from 'lwc';

import PaginationTemplate from '@salesforce/label/c.PaginationTemplate';
import PaginationPageSizeError from '@salesforce/label/c.PaginationPageSizeError';
import PaginationListSizeError from '@salesforce/label/c.PaginationListSizeError';
export default class Pagination extends LightningElement {
	// It's used to set number of items on one page
	_pageSize;
	@api get pageSize() {
		return this._pageSize;
	}
	set pageSize(value) {
		if (value) {
			this._pageSize = parseInt(value);
		}
	}

	// It's used to set number of all items
	_listSize;
	@api get listSize() {
		return this._listSize;
	}
	set listSize(value) {
		if (!isNaN(parseInt(value)) ) {
			this._listSize = parseInt(value);
		}
	}

	// It's used to set current page number
	@api currentPage = 1;

	// It's used to replace standard pagination text
	_paginationMsg;
	@api get paginationMsg() {
		let result = PaginationTemplate;

		return this._paginationMsg || result
			.replace('{0}', this.startView.toString())
			.replace('{1}', this.endView.toString())
			.replace('{2}', this.listSize.toString());
	}
	set paginationMsg(value) {
		if (value) {
			this._paginationMsg = value;
		}
	}

	/**
	 * Handler for the Previous button
	 */
	@api handlePrev() {
		if (!this.disabled.prev) {
			this.currentPage--;
		}
		this.dispatchPaginationEvent();
	}

	/**
	 * Handler for the Next button
	 */
	@api handleNext() {
		if (!this.disabled.next) {
			this.currentPage++
		}
		this.dispatchPaginationEvent();
	}

	get errorMessages() {
		let messages = [];
		if (isNaN(this.pageSize) || this.pageSize === 0 ) {
			messages.push(PaginationPageSizeError.replace('{0}',this.pageSize));
		}
		if (isNaN(this.listSize)) {
			messages.push(PaginationListSizeError.replace('{0}', this.listSize))
		}

		return messages;
	}

	get show() {
		return {
			errorMessage: this.errorMessages.length > 0,
			pagination: this.errorMessages.length === 0,
		}
	}

	get allPages() {
		return this._listSize % this._pageSize ?
			parseInt(this.listSize / this.pageSize) + 1 :
			parseInt(this.listSize / this.pageSize);
	}

	get startView() {
		return this.listSize > 0 ? (this.currentPage * this.pageSize) - this.pageSize + 1 : 0;
	};

	get endView() {
		let temp = this.currentPage * this.pageSize;
		return temp > this.listSize ? this.listSize : temp;
	};

	get disabled() {
		return {
			prev: this.currentPage === 1 || this.listSize === 0 ,
			next: this.currentPage === this.allPages || this.listSize === 0,
		}
	}

	dispatchPaginationEvent() {
		this.dispatchEvent(new CustomEvent('pagination',{
			detail:{
				offset: this.startView === 0 ? 0 : this.startView - 1,
				pageSize: this.pageSize
			}
		}));
	}
}