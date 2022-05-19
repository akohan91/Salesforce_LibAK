/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
public with sharing class SobjectTableServiceDefault extends SobjectTableServiceAbstract {
	private static final Map<Schema.DisplayType, String> DISPLAY_TYPE_TO_DATATABLE_TYPE_MAP = new Map<Schema.DisplayType, String>{
		Schema.DisplayType.id =>            'text',
		Schema.DisplayType.address =>       'text',
		Schema.DisplayType.anytype =>       'text',
		Schema.DisplayType.base64 =>        'text',
		Schema.DisplayType.Boolean =>       'boolean',
		Schema.DisplayType.Combobox =>      'text',
		Schema.DisplayType.Currency =>      'currency',
		Schema.DisplayType.Date =>          'date',
		Schema.DisplayType.DateTime =>      'date',
		Schema.DisplayType.Double =>        'number',
		Schema.DisplayType.Email =>         'email',
		Schema.DisplayType.Integer =>       'number',
		Schema.DisplayType.MultiPicklist => 'text',
		Schema.DisplayType.Percent =>       'percent',
		Schema.DisplayType.Phone =>         'phone',
		Schema.DisplayType.Picklist =>      'text',
		Schema.DisplayType.String =>        'text',
		Schema.DisplayType.TextArea =>      'text',
		Schema.DisplayType.Time =>          'date',
		Schema.DisplayType.URL =>           'url'
	};

	private Set<String> fieldPathsToRetrieve;
	private List<DynamicSOQLFunction> retriveFunctions;
	private List<String> addressFieldPaths;
	private List<String> referenceFieldPaths;
	private List<Object> dataTableColumns;
	private Map<String, Schema.DescribeFieldResult> targetFieldDescribeByPath;

	public override List<SObject> sobjectRecords() {
		if (this.targetFieldDescribeByPath == null) {
			this.processFieldPaths();
		}
		DynamicSOQL soql = new DynamicSOQL(this.sobjectName);
		for (String fieldPath : fieldPathsToRetrieve) {
			soql.withField(fieldPath);
		}
		for (DynamicSOQLFunction function : retriveFunctions) {
			soql.withFunction(function);
		}
		soql.withConditions(this.conditionBlock);
		soql.withLimit(this.limitRecords);
		soql.withOffset(this.offsetRecords);

		return Database.query(soql.toString());
	}

	public override Integer recordsCount() {
		return Database.countQuery(
			new DynamicSOQL(this.sobjectName)
			.withFunction(new DynamicSOQLFunction('COUNT'))
			.withConditions(this.conditionBlock)
			.toString()
		);
	}

	public override List<String> addressFieldPaths() {
		if (this.targetFieldDescribeByPath == null) {
			this.processFieldPaths();
		}
		return this.addressFieldPaths;
	}

	public override List<String> referenceFieldPaths() {
		if (this.targetFieldDescribeByPath == null) {
			this.processFieldPaths();
		}
		return this.referenceFieldPaths;
	}

	public override List<Object> dataTableColumns() {
		if (this.targetFieldDescribeByPath == null) {
			this.processFieldPaths();
		}
		if (this.dataTableColumns != null) {
			return this.dataTableColumns;
		}
		this.dataTableColumns = new List<Object>();
		for (String fieldPath : this.targetFieldDescribeByPath.keySet()) {
			Schema.DescribeFieldResult targetFieldDescribe = this.targetFieldDescribeByPath.get(fieldPath);
			Map<String, Object> dataTableColumn = new Map<String, Object>();
			if (targetFieldDescribe.getType() == Schema.DisplayType.ID ||
				targetFieldDescribe.getType() == Schema.DisplayType.REFERENCE
			) {
				String nameFieldPath = this.nameFieldForReference(fieldPath);
				dataTableColumn.put('fieldName', fieldPath);
				dataTableColumn.put('label', targetFieldDescribe.getLabel());
				dataTableColumn.put('type', 'url');
				dataTableColumn.put('typeAttributes', new Map<String, Object>{
					'label' => new Map<String, Object>{'fieldName' => nameFieldPath},
					'tooltip' => new Map<String, Object>{'fieldName' => nameFieldPath}
				});
			} else {
				dataTableColumn.put('fieldName', fieldPath);
				dataTableColumn.put('label', targetFieldDescribe.getLabel());
				dataTableColumn.put('type', this.dataTableTypeFromDisplayType(targetFieldDescribe.getType()));
			}
			this.dataTableColumns.add(dataTableColumn);
		}
		return this.dataTableColumns;
	}

	private void processFieldPaths() {
		this.fieldPathsToRetrieve = new Set<String>();
		this.retriveFunctions = new List<DynamicSOQLFunction>();
		this.addressFieldPaths = new List<String>();
		this.referenceFieldPaths = new List<String>();
		this.targetFieldDescribeByPath = new Map<String, Schema.DescribeFieldResult>();
		for (String fieldPath : this.selectFields) {
			fieldPath = fieldPath.toLowerCase();
			Schema.DescribeFieldResult targetFieldDescribe =
				new SobjectFieldPath(this.sobjectName, fieldPath).targetFieldDescribe();
			this.targetFieldDescribeByPath.put(fieldPath, targetFieldDescribe);

			if (targetFieldDescribe.getType() == Schema.DisplayType.ID) {
				this.fieldPathsToRetrieve.add('id');
				this.fieldPathsToRetrieve.add('name');
				this.referenceFieldPaths.add(fieldPath);
			} else if (targetFieldDescribe.getType() == Schema.DisplayType.PICKLIST) {
				this.retriveFunctions.add(new DynamicSOQLFunction('toLabel', fieldPath));
			} else if (targetFieldDescribe.getType() == Schema.DisplayType.REFERENCE) {
				this.fieldPathsToRetrieve.add(fieldPath);
				this.referenceFieldPaths.add(fieldPath);
				this.fieldPathsToRetrieve.add(this.nameFieldForReference(fieldPath));
			} else if (targetFieldDescribe.getType() == Schema.DisplayType.ADDRESS) {
				this.fieldPathsToRetrieve.add(fieldPath);
				this.addressFieldPaths.add(fieldPath);
			} else {
				this.fieldPathsToRetrieve.add(fieldPath);
			}
		}
	}

	private String nameFieldForReference(String fieldPath) {
		if (fieldPath == 'id') {
			return 'name';
		} else if (fieldPath.endsWithIgnoreCase('id')) {
			return fieldPath.removeEnd('id') + '.name';
		} else if (fieldPath.endsWithIgnoreCase('__c')) {
			return fieldPath.removeEnd('__c') + '__r.name';
		} else {
			throw new SobjectTableServiceDefaultException('Not reference path: ' + fieldPath);
		}
	}

	private String dataTableTypeFromDisplayType(Schema.DisplayType type) {
		if (DISPLAY_TYPE_TO_DATATABLE_TYPE_MAP.containsKey(type)) {
			return DISPLAY_TYPE_TO_DATATABLE_TYPE_MAP.get(type);
		} else {
			return 'text';
		}
	}

	public class SobjectTableServiceDefaultException extends Exception {}
}
