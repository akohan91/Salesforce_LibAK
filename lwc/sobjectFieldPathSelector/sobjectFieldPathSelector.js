import { LightningElement, api, wire } from 'lwc';
import { showErrorModal } from 'c/lwcUtils'
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

const SOQL_LEVELS_LIMIT = 5;

export default class SobjectFieldPathSelector extends LightningElement {
	@api sobjectName;
	@api getPath() {
		try {
			return this.fieldPath.reduce((result, field, index) => (
				this.fieldPath.length - 1 !== index ?
				result += field.relationshipName + '.' :
				result += field.apiName
			),'');
		} catch (error) {
			showErrorModal(error, this);
		}
	}

	sobjectLabel;
	availableFields = [];
	fieldPath = [];
	isBusy = true;

	get show() {
		try {
			return {
				content: this.sobjectName,
				spinner: this.isBusy,
			}
		} catch (error) {
			showErrorModal(error, this);
		}
	}

	get comboboxFieldOptions() {
		try {
			if (this.currentSobjectName && this.fieldPath.length <= SOQL_LEVELS_LIMIT) {
				return this.availableFields.map(field => ({
					label: field.label + (field.referenceToInfos.length > 0 ? ' >' : ''),
					value: field.apiName
				}));
			} else {
				return [];
			}
		} catch (error) {
			showErrorModal(error, this);
		}
	}

	get currentSobjectName() {
		try {
			if (this.fieldPath.length === 0) {
				return this.sobjectName;
			} else if (this.fieldPath.at(-1).referenceToInfos.length > 0) {
				return this.fieldPath.at(-1).referenceToInfos[0].apiName
			} else {
				return;
			}
		} catch (error) {
			showErrorModal(error, this);
		}
	}

	@wire(getObjectInfo, { objectApiName: '$currentSobjectName' })
	objectInfo({data, error}){
		try {
			if (error) {
				this.availableFields = [];
			} else if (data) {
				const {fields, apiName, label} = data;
				if (this.sobjectName === apiName) {
					this.sobjectLabel = label
				}
				this.availableFields = [];
				Object.values(fields).forEach(field => {
					if (field.referenceToInfos.length > 1) {
						return;
					}
					if (field.reference && field.relationshipName) {
						this.availableFields.push({...field, referenceToInfos: []});
						this.availableFields.push({...field, apiName: field.relationshipName});
						return;
					}
					this.availableFields.push(field);
				});
			}
		} catch (error) {
			showErrorModal(error, this);
		} finally {
			this.ready();
		}
	};

	busy = () => (this.isBusy = true);
	ready = () => (this.isBusy = false);

	handleSelectField(event) {
		try {
			const selectedField = this.availableFields.find(field => field.apiName === event.detail.value);
			this.fieldPath = [...this.fieldPath, {
				...selectedField,
				id: this.fieldPath.length
			}];
		} catch (error) {
			showErrorModal(error, this);
		}
	}

	handlePathItemClick(event) {
		try {
			this.fieldPath = this.fieldPath.slice(0, parseInt(event.target.dataset.id));
		} catch (error) {
			showErrorModal(error, this);
		}
	}
}