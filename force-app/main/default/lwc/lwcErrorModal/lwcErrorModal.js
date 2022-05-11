/**
The component shows the error in the modal window
To use it you should:
	1. put the "<c-lwc-error-modal></c-lwc-error-modal>" code to the markup of the parent component.
	2. Import the "showErrorModal" method from lwcUtils and call it with two parameters - "error" and "this" (parent component) like this:
		showErrorModal(error, this);
*/

import { api, LightningElement } from 'lwc';

import ErrorHappened from '@salesforce/label/c.ErrorHappened';

export default class LwcErrorModal extends LightningElement {
	message;
	stackTrace;

	label = {
		ErrorHappened
	}

	/**
	 * Opens the LWC Modal component with the error information
	 * @param { ErrorInformation } errorInformation
	 */
	@api showErrorModal(errorInformation) {
		try {
			this.message = errorInformation.message;
			this.stackTrace = errorInformation.stackTrace;
			this.template.querySelector('c-lwc-modal')?.openModal();
		} catch (error) {
			console.error(error);
		}
	}

	/**
	 * Closes the error modal component
	 */
	handleCloseModal() {
		this.message = null;
		this.stackTrace = null;
	}
}