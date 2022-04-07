import { ErrorInformation } from "./ErrorInformation";

const showErrorModal = (error, that) => {
	that.template.querySelector('c-lwc-error-modal')?.showErrorModal(
		new ErrorInformation(error)
	);
}

export {
	showErrorModal,
};