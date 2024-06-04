/**
 * @author Andrei Kakhanouski <akohan91@gmail.com>
 * The class is used as a service for the SobjectTableCtrl class.
 *
 * Properties of SobjectTableServiceAbstract class:
 * @property sobjectName    { String }
 * @property selectFields   { List<String> }
 * @property conditionBlock { DynamicSOQLConditionBlock }
 * @property orderBy        { DynamicSOQLOrderBy }
 * @property limitRecords   { Integer }
 * @property offsetRecords  { Integer }
 *
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
	private List<DataTableColumn> dataTableColumns;
	private Map<String, SobjectFieldPathInterface> targetFieldPathItemByPath;

	public class Constructor implements SobjectTableServiceAbstract.IConstructable {
		public SobjectTableServiceAbstract construct(String inputJSON) {
			return (SobjectTableServiceAbstract)JSON.deserialize(inputJSON, SobjectTableServiceDefault.class);
		}
	}

	/* PUBLIC METHODS */

	/**
	 * @description Returns the list of Sobject records
	 * @return   { List<SObject> }
	 */
	public override List<SObject> sobjectRecords() {
		this.processFieldPaths();
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
		return Database.query(soql.stringify());
	}

	/**
	 * @description Returns the number of Sobject records.
	 * @return   { Integer }
	 */
	public override Integer recordsCount() {
		return Database.countQuery(
			new DynamicSOQL(this.sobjectName)
			.withFunction(new DynamicSOQLFunction('COUNT'))
			.withConditions(this.conditionBlock)
			.stringify()
		);
	}

	/**
	 * @description Returns the list of field paths that have ADDRESS display type
	 * @return   { List<String> }
	 */
	public override List<String> addressFieldPaths() {
		this.processFieldPaths();
		return this.addressFieldPaths;
	}

	/**
	 * @description Returns the list of field paths that have ID or REFERENCE display type
	 * @return   { List<String> }
	 */
	public override List<String> referenceFieldPaths() {
		this.processFieldPaths();
		return this.referenceFieldPaths;
	}

	/**
	 * @description Returns the list of LWC dataTable columns
	 * @return   { List<Object> }
	 */
	public override List<Object> dataTableColumns() {
		if (this.dataTableColumns != null) {
			return this.dataTableColumns;
		}
		this.processFieldPaths();
		this.dataTableColumns = new List<DataTableColumn>();
		for (SobjectFieldPathInterface fieldPath : this.targetFieldPathItemByPath.values()) {
			DataTableColumn dataTableColumn;

			if (fieldPath.targetFieldDescribe().getType() == Schema.DisplayType.ID ||
				fieldPath.targetFieldDescribe().getType() == Schema.DisplayType.REFERENCE ||
				fieldPath.targetFieldDescribe().isNameField()
			) {
				dataTableColumn = new DataTableColumn(
					fieldPath.targetReferencePath() + '_link',
					fieldPath.targetFieldDescribe().getLabel(),
					this.dataTableTypeFromDisplayType(Schema.DisplayType.URL)
				).withtypeAttributes(new Map<String, Object>{
					'label' => new Map<String, Object>{'fieldName' => fieldPath.path()},
					'tooltip' => new Map<String, Object>{'fieldName' => fieldPath.path()}
				});
			} else {
				dataTableColumn = new DataTableColumn(
					fieldPath.path(),
					fieldPath.targetFieldDescribe().getLabel(),
					this.dataTableTypeFromDisplayType(fieldPath.targetFieldDescribe().getType())
				);
			}
			dataTableColumn.withColumnKey(fieldPath.path());
			dataTableColumn.withSortable(fieldPath.targetFieldDescribe().isSortable());
			this.dataTableColumns.add(dataTableColumn);
		}
		return this.dataTableColumns;
	}

	/* PRIVATE METHODS */

	private void processFieldPaths() {
		if (this.targetFieldPathItemByPath != null) {
			return;
		}
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
