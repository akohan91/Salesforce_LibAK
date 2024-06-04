import { LightningElement } from 'lwc';

export default class DemoSobjectTable extends LightningElement {
	tableWithCustomBackend = {
		controllerName: 'TableWithCustomBackendCtrl',
		columnsToOverride: [{
			action: 'OVERRIDE',
			fieldName: 'Origin',
			column: {
				cellAttributes: {
					iconName: { fieldName: 'originicon' },
					iconLabel: { fieldName: 'origin' },
					iconPosition: 'left',
				},
			},
		}]
	}
}