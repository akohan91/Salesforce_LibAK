class ErrorInformation {
	message = '';
	stackTrace = '';

	constructor(error) {
		try {
			console.error(error);
			this.addPageErrors(error);
			this.addFieldErrors(error);
			this.addOtherErrors(error);
		} catch (e) {
			console.error(e);
			console.error(error);
			this.message += JSON.stringify(error);
			this.stackTrace += JSON.stringify(error);
		}
	}

	addPageErrors(error) {
		if (
			error.body &&
			error.body.pageErrors &&
			error.body.pageErrors instanceof Array
		) {
			error.body.pageErrors.forEach((pageError) => {
				this.message += pageError.message;
			});
		}
	}

	addFieldErrors(error) {
		if (
			error.body &&
			error.body.fieldErrors &&
			error.body.fieldErrors instanceof Array
		) {
			error.body.fieldErrors.forEach((fieldError) => {
				this.message += fieldError.message;
			});
		}
	}

	addOtherErrors(error) {
		if (error.message) {
			this.message += error.message;
		}
		if (error.stackTrace) {
			this.stackTrace += error.stackTrace;
		}

		if (error.body && error.body.message) {
			this.message += error.body.message;
		}

		if (error.body && error.body.stackTrace) {
			this.stackTrace += error.body.stackTrace;
		}

		if (error.stack) {
			this.stackTrace += error.stack;
		}

		if (!this.stackTrace) {
			this.stackTrace = JSON.stringify(error);
		}
	}
}

const showErrorModal = (error, that) => {
	that.template.querySelector('c-lwc-error-modal')?.showErrorModal(
		new ErrorInformation(error)
	);
}

export {
	showErrorModal,
};