import { ErrorInformation } from "./ErrorInformation";

/**
 *
 * @param { Error } error - JavaScript Error
 * @param { LightningElement } that - the component instance where the error should be shown
 */
const showErrorModal = (error, that) => {
	that.template.querySelector('c-lwc-error-modal')?.showErrorModal(
		new ErrorInformation(error)
	);
}

export {
	showErrorModal,
};