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
	private Map<String, SobjectFieldPathInterface> targetFieldPathItemByPath;

	/* PUBLIC METHODS */

	public override List<SObject> sobjectRecords() {
		if (this.targetFieldPathItemByPath == null) {
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
		soql.withOrderBy(this.orderBy);
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
		if (this.targetFieldPathItemByPath == null) {
			this.processFieldPaths();
		}
		return this.addressFieldPaths;
	}

	public override List<String> referenceFieldPaths() {
		if (this.targetFieldPathItemByPath == null) {
			this.processFieldPaths();
		}
		return this.referenceFieldPaths;
	}

	public override List<Object> dataTableColumns() {
		if (this.targetFieldPathItemByPath == null) {
			this.processFieldPaths();
		}
		if (this.dataTableColumns != null) {
			return this.dataTableColumns;
		}
		this.dataTableColumns = new List<Object>();
		for (SobjectFieldPathInterface fieldPath : this.targetFieldPathItemByPath.values()) {
			Map<String, Object> dataTableColumn = new Map<String, Object>{
				'sortable' => fieldPath.targetFieldDescribe().isSortable(),
				'columnKey' => fieldPath.path()
			};

			if (fieldPath.targetFieldDescribe().getType() == Schema.DisplayType.ID ||
				fieldPath.targetFieldDescribe().getType() == Schema.DisplayType.REFERENCE ||
				fieldPath.targetFieldDescribe().isNameField()
			) {
				dataTableColumn.put('fieldName', fieldPath.targetReferencePath() + '_link');
				dataTableColumn.put('label', fieldPath.targetFieldDescribe().getLabel());
				dataTableColumn.put('type', 'url');
				dataTableColumn.put('typeAttributes', new Map<String, Object>{
					'label' => new Map<String, Object>{'fieldName' => fieldPath.path()},
					'tooltip' => new Map<String, Object>{'fieldName' => fieldPath.path()}
				});
			} else {
				dataTableColumn.put('fieldName', fieldPath.path());
				dataTableColumn.put('label', fieldPath.targetFieldDescribe().getLabel());
				dataTableColumn.put('type', this.dataTableTypeFromDisplayType(fieldPath.targetFieldDescribe().getType()));
			}
			this.dataTableColumns.add(dataTableColumn);
		}
		return this.dataTableColumns;
	}

	/* PRIVATE METHODS */

	private void processFieldPaths() {
		this.fieldPathsToRetrieve = new Set<String>();
		this.retriveFunctions = new List<DynamicSOQLFunction>();
		this.addressFieldPaths = new List<String>();
		this.referenceFieldPaths = new List<String>();
		this.targetFieldPathItemByPath = new Map<String, SobjectFieldPathInterface>();

		for (String fieldPathStr : this.selectFields) {
			fieldPathStr = fieldPathStr.toLowerCase();
			SobjectFieldPathInterface fieldPath = new SobjectFieldPath(this.sobjectName, fieldPathStr);
			this.targetFieldPathItemByPath.put(fieldPath.path(), fieldPath);

			this.fieldPathsToRetrieve.add(fieldPath.path());
			if (fieldPath.targetFieldDescribe().getType() == Schema.DisplayType.ID ||
				fieldPath.targetFieldDescribe().getType() == Schema.DisplayType.REFERENCE ||
				fieldPath.targetFieldDescribe().isNameField()
			) {
				this.fieldPathsToRetrieve.add(fieldPath.targetReferencePath());
				this.referenceFieldPaths.add(fieldPath.targetReferencePath());
			} else if (fieldPath.targetFieldDescribe().getType() == Schema.DisplayType.PICKLIST) {
				this.fieldPathsToRetrieve.remove(fieldPath.path());
				this.retriveFunctions.add(new DynamicSOQLFunction('toLabel', fieldPath.path()));
			} else if (fieldPath.targetFieldDescribe().getType() == Schema.DisplayType.ADDRESS) {
				this.addressFieldPaths.add(fieldPath.path());
			}
		}
	}

	private String dataTableTypeFromDisplayType(Schema.DisplayType type) {
		return DISPLAY_TYPE_TO_DATATABLE_TYPE_MAP.containsKey(type) ?
			DISPLAY_TYPE_TO_DATATABLE_TYPE_MAP.get(type) :
			'text';
	}

	public class SobjectTableServiceDefaultException extends Exception {}
}
