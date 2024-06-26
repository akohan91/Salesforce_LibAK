public with sharing class TableWithCustomBackendCtrl extends SobjectTableServiceAbstract {
	private SobjectTableServiceAbstract service;

	public class Constructor implements SobjectTableServiceAbstract.IConstructable {
		public SobjectTableServiceAbstract construct(String inputJSON) {
			return new TableWithCustomBackendCtrl(
				new SobjectTableServiceDefault.Constructor().construct(inputJSON)
			);
		}
	}

	public TableWithCustomBackendCtrl(SobjectTableServiceAbstract defaultService) {
		this.service = defaultService;
	}

	override public List<Object> tableRows() {
		List<Map<String,Object>> rows = new List<Map<String,Object>>();
		for (Case caseItem : (List<Case>)this.sobjectRecords()) {
			Map<String,Object> row = new Map<String,Object>();
			row.putAll(caseItem.getPopulatedFieldsAsMap());
			if (caseItem.Origin == 'Email') {
				row.put('originIcon', 'utility:email');
			} else if (caseItem.Origin == 'Phone') {
				row.put('originIcon', 'utility:call');
			} else if (caseItem.Origin == 'Web') {
				row.put('originIcon', 'utility:link');
			} else {
				row.put('originIcon', 'utility:question_mark');
			}
			rows.add(row);
		}
		return rows;
	}

	override public List<SObject> sobjectRecords() {
		return this.service.sobjectRecords();
	}

	override public Integer recordsCount() {
		return this.service.recordsCount();
	}

	override public List<String> addressFieldPaths() {
		return this.service.addressFieldPaths();
	}

	override public List<String> referenceFieldPaths() {
		return this.service.referenceFieldPaths();
	}

	override public List<Object> dataTableColumns() {
		return this.service.dataTableColumns();
	}
}