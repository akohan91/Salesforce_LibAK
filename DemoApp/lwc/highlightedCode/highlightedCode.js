import { LightningElement, api } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import prismJS from '@salesforce/resourceUrl/prismJS';
import prismCSS from '@salesforce/resourceUrl/prismCSS';

import { showErrorModal } from 'c/lwcUtils';

const RESET_COPY_BTN_TIME = 3000;
const COPY_BTN_STATE = {
	readyToCopy: {
		label: 'Copy',
		icon: 'utility:copy_to_clipboard',
		isCopied: false
	},
	copied: {
		label: 'Copied',
		icon: 'utility:check',
		isCopied: true
	}
}

export default class HighlightedCode extends LightningElement {
	@api title;
	@api language; // html | css | javascript | apex
	@api code;
	copyBtnState = COPY_BTN_STATE.readyToCopy;
	get languageCssClass() {
		return this.language && `language-${this.language}` || '';
	}
	isPrismLoaded = false;

	renderedCallback() {
		this.highlightCode();
	}

	handleCopy() {
		navigator.clipboard.writeText(this.code)
		.then(() => {
			this.switchCopyBtnState();
		}).catch((error) => {
			showErrorModal(error, this);
		});
	}

	prepareCodeBlock() {
		try {
			const codeBlock = document.createElement('code');
			codeBlock.className = this.languageCssClass;
			codeBlock.innerText = this.code;
			codeBlock.innerHTML = codeBlock.innerHTML.replaceAll('<br>', '\n');
			return codeBlock;
		} catch (error) {
			showErrorModal(error, this);
		}
	}

	highlightCode() {
		if (this.isPrismLoaded) {
			this.appendToPreBlock(this.prepareCodeBlock());
			return;
		}
		Promise.all([
			loadStyle(this, prismCSS),
			loadScript(this, prismJS),
		]).then(() => {
			this.isPrismLoaded = true;
			this.appendToPreBlock(this.prepareCodeBlock());
		}).catch((error) => {
			showErrorModal(error, this);
		})
	}

	appendToPreBlock(codeBlock) {
		try {
			Prism.highlightElement(codeBlock);
			const preBlock = this.template.querySelector('.pre-block');
			preBlock.innerHTML = null;
			preBlock.appendChild(codeBlock);
		} catch (error) {
			showErrorModal(error, this);
		}
	}

	switchCopyBtnState() {
		try {
			this.copyBtnState = COPY_BTN_STATE.copied;
			setTimeout(() => {
				this.copyBtnState = COPY_BTN_STATE.readyToCopy
			}, RESET_COPY_BTN_TIME);
		} catch (error) {
			showErrorModal(error, this);
		}
	}
}