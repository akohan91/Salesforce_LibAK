/**
 * @author Andrei Kakhanouski <akohan91@gmail.com>
 */
import { LightningElement, api } from 'lwc';

import Cancel from '@salesforce/label/c.Cancel';

export default class LwcModal extends LightningElement {
	// It's used to set the width of the modal. Values: 'small' | 'medium' | 'large'
	@api size = 'small';
	// It's used to hide the footer of the modal
	@api hideFooter = false;
	// It's used to hide the header of the modal
	@api hideHeader = false;
	/**
	 * @description Close the modal and returns the Promise to determine the moment when the modal will be closed
	 * @returns { Promise }
	 */
	@api closeModal() {
		return new Promise(resolve => {
			this.isOpened = false;
			this.dispatchEvent(new CustomEvent('modalclosed'));
			resolve();
		});
	}
	/**
	 * @description Open the modal and returns the Promise to determine the moment when the modal will be Opened
	 * @returns { Promise }
	 */
	@api openModal() {
		return new Promise(resolve => {
			this.isOpened = true;
			resolve();
		});
	}

	get modalClass() { return `slds-modal slds-fade-in-open slds-modal_${this.size}`; }
	get headerClass() { return `slds-modal__header ${this.hideHeader && 'hidden-header'}`; }

	isOpened = false;
	label = {
		Cancel
	}
}