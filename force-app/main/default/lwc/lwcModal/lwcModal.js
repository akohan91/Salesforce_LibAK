import { LightningElement, api } from 'lwc';

import Cancel from '@salesforce/label/c.Cancel';

export default class LwcModal extends LightningElement {
	@api size = 'small';
	@api hideFooter = false;
	@api hideHeader = false;
	@api errorModal;
	@api closeModal() {
		return new Promise(resolve => {
			this.isOpened = false;
			this.dispatchEvent(new CustomEvent('modalclosed'));
			resolve();
		});
	}
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