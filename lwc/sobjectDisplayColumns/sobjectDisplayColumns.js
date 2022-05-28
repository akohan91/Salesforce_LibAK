import { LightningElement, api } from 'lwc';
import { showErrorModal } from 'c/lwcUtils';

export default class SobjectDisplayColumns extends LightningElement {
	@api sobjectName;
	_fieldPaths = [];
	@api get fieldPaths() {
		return this._fieldPaths;
	};
	set fieldPaths(value) {
		if (value) {
			this._fieldPaths = value.map((fieldPath, index) => {
				if (typeof fieldPath === 'string') {
					return {
						id: Math.random().toString(16).slice(2),
						value: fieldPath,
						order: index,
					}
				} else {
					return fieldPath;
				}
			});
		}
	}

	draggableSourceId;

	@api getDisplayColumns() {
		try {
			return [...this.template.querySelectorAll('c-sobject-field-path-selector.display-column')]
			.map(displayColumn => displayColumn.getPath());
		} catch (error) {
			showErrorModal(error, this);
		}
	}

	handleRemovePath(event) {
		try {
			this.fieldPaths = this.fieldPaths
			.filter(fieldPath => fieldPath.id !== event.target.dataset.id)
			.map((fieldPath, index) => ({
				...fieldPath,
				order: index
			}))
		} catch (error) {
			showErrorModal(error, this);
		}
	}

	handleAddPath() {
		this.fieldPaths = [...this.fieldPaths, {
			id: Math.random().toString(16).slice(2),
			value: undefined,
			order: this.fieldPaths.length,
		}];
	}

	handleDragFieldPath(event) {
		try {
			this.draggableSourceId = event.target.dataset.id;
		} catch (error) {
			showErrorModal(error, this);
		}
	}

	handleDragOverFieldPath(event) {
		try {
			event.preventDefault();
			const draggableTargetId = event.target.dataset.id;
			if (this.draggableSourceId === draggableTargetId) { return; }
			const source = this.fieldPaths.find(fieldPath => fieldPath.id === this.draggableSourceId);
			const target = this.fieldPaths.find(fieldPath => fieldPath.id === draggableTargetId);
			const sourceOrder = source.order;
			const targetOrder = target.order;
			source.order = targetOrder;
			target.order = sourceOrder;
			this.fieldPaths = this.fieldPaths.sort((a, b) => a.order - b.order);
		} catch (error) {
			showErrorModal(error, this);
		}
	}

	handleDropFieldPath(event) {
		event.preventDefault();
	}
}