public with sharing class DynamicSOQLConstants {
	public static final Map<String,Schema.SObjectType> GLOBAL_DESCRIBE = Schema.getGlobalDescribe();
	public static final String TMPL_QUERY =
		'SELECT {selectItems} FROM {SObject} {WHERE} {GROUP BY} {ORDER BY} {LIMIT} {OFFSET}';
	public static final String TMPL_CONDITION = '{leftPart} {operator} {rightPart}';
	public static final String TMPL_BULK_VALUES = '({values})';
	public static final String TMPL_FUNCTION = '{functionName}({fieldName}) {alias}';
	public static final String TMPL_GROUP_BY = 'GROUP BY {fieldGroupByList}{HAVING}';
	public static final String TMPL_ORDER_BY = 'ORDER BY {fieldOrderByList} {direction} {NULLS}';

	public static final String PH_SELECT_ITEMS = '{selectItems}';
	public static final String PH_SOBJECT = '{SObject}';
	public static final String PH_WHERE = '{WHERE}';
	public static final String PH_GROUP_BY = '{GROUP BY}';
	public static final String PH_ORDER_BY = '{ORDER BY}';
	public static final String PH_LIMIT = '{LIMIT}';
	public static final String PH_OFFSET = '{OFFSET}';
	public static final String PH_LEFT_PART = '{leftPart}';
	public static final String PH_OPERATOR = '{operator}';
	public static final String PH_AVAILABLE_OPERATORS = '{availableOperators}';
	public static final String PH_RIGHT_PART = '{rightPart}';
	public static final String PH_BULK_VALUES = '{values}';
	public static final String PH_FUNCTION_NAME = '{functionName}';
	public static final String PH_FIELD_NAME = '{fieldName}';
	public static final String PH_ALIAS = '{alias}';
	public static final String PH_FIELD_GROUP_BY_LIST = '{fieldGroupByList}';
	public static final String PH_HAVING = '{HAVING}';
	public static final String PH_FIELD_ORDER_BY_LIST = '{fieldOrderByList}';
	public static final String PH_DIRECTION = '{direction}';
	public static final String PH_NULLS = '{NULLS}';

	public static final String EMPTY_STRING = '';
	public static final String COMMA = ',';
	public static final String SEMICOLON = ';';
	public static final String COLON = ':';
	public static final String SINGLE_QUOTE	= '\'';

	public static final String OPERATOR_INCLUDES = 'INCLUDES';
	public static final String OPERATOR_EXCLUDES = 'EXCLUDES';
	public static final Set<String> CONDITION_BLOCK_AVAILABLE_OPERATORS = new Set<String>{ 'AND', 'OR' };
	public static final Set<String> CONDITION_AVAILABLE_OPERATORS = new Set<String>{
		'=',
		'!=',
		'<',
		'<=',
		'>',
		'>=',
		'LIKE',
		'IN',
		'NOT IN',
		'INCLUDES',
		'EXCLUDES'
	};
	public static final Set<Schema.DisplayType> TEXT_DISPLAY_TYPES = new Set<Schema.DisplayType> {
		Schema.DisplayType.id,
		Schema.DisplayType.address,
		Schema.DisplayType.anytype,
		Schema.DisplayType.base64,
		Schema.DisplayType.Combobox,
		Schema.DisplayType.Email,
		Schema.DisplayType.MultiPicklist,
		Schema.DisplayType.Phone,
		Schema.DisplayType.Picklist,
		Schema.DisplayType.String,
		Schema.DisplayType.TextArea,
		Schema.DisplayType.URL
	};

	public static final String NULL_STRING = 'null';

	public static final String FORMAT_DATE_TIME = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
	public static final String FORMAT_DATE = 'yyyy-MM-dd';
	public static final String FORMAT_TIME_SEPARATOR = 'T';

	public static final String SORT_DIRECTION_DESC = 'DESC';
	public static final String SORT_DIRECTION_ASC = 'ASC';
	public static final String NULLS_FIRST = 'NULLS FIRST';
	public static final String NULLS_LAST = 'NULLS LAST';
}