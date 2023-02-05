/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
public with sharing class DynamicSOQLCondition {
	private final static Set<String> AVAILABLE_OPERATORS = new Set<String>{
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
	private final static Set<Schema.DisplayType> TEXT_DISPLAY_TYPES = new Set<Schema.DisplayType> {
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
	@TestVisible
	private DynamicSOQLFunction function;
	@TestVisible
	private String fieldName;
	@TestVisible
	private String operator;
	@TestVisible
	private String value;
	@TestVisible
	private List<String> values;

	// CONSTRUCTORS

	public DynamicSOQLCondition(String fieldName, String operator, Object value) {
		this(fieldName, operator);
		this.value = String.valueOf(value);
	}

	public DynamicSOQLCondition(DynamicSOQLFunction function, String operator, Object value) {
		this(null, operator);
		this.function = function;
		this.value = String.valueOf(value);
	}

	public DynamicSOQLCondition(String fieldName, String operator, Datetime value) {
		this(fieldName, operator);
		this.value = this.fmtDatetime(value);
	}

	public DynamicSOQLCondition(String fieldName, String operator, Date value) {
		this(fieldName, operator);
		this.value = this.fmtDate(value);
	}

	public DynamicSOQLCondition(String fieldName, String operator, String value) {
		this(fieldName, operator);
		this.value = value == null ? 'null' : value;
	}

	private DynamicSOQLCondition(String fieldName, String operator) {
		this.fieldName = fieldName;
		this.operator = operator;
	}

	// PUBLIC METHOD

	/**
	 * @description Returns the field api name that is used in the condition.
	 * @return   { String }
	 */
	public String fieldApiName() {
		if (this.fieldName != null) {
			return this.fieldName;
		} else if (this.function != null) {
			return this.function.fieldApiName();
		} else {
			throw new DynamicSOQLConditionException(Label.NoFieldApiNameInSOQLCondition);
		}
	}

	/**
	 * @description Build the SOQL condition as a string in format <fieldApiName> <operator> <value>.
	 * @param  sobjectApiName { String } Sobject api name for what the condition is created.
	 * @return   { String }
	 */
	public String stringify(String sobjectApiName) {
		String resultTemplate = '{fieldName} {operator} {value}';
		DescribeFieldResult fieldDescribe = new SobjectFieldPath(sobjectApiName, this.fieldApiName()).targetFieldDescribe();
		this.validateOperator();
		if (this.function != null) {
			return resultTemplate
				.replace('{fieldName}', this.function.stringify())
				.replace('{operator}', String.escapeSingleQuotes(this.operator))
				.replace('{value}', String.escapeSingleQuotes(this.value));
		} else if (this.value == null && this.values != null) {
			return resultTemplate
				.replace('{fieldName}', String.escapeSingleQuotes(this.fieldName))
				.replace('{operator}', String.escapeSingleQuotes(this.operator))
				.replace('{value}', this.stringifyValues(fieldDescribe));
		} else {
			return resultTemplate
				.replace('{fieldName}', String.escapeSingleQuotes(this.fieldName))
				.replace('{operator}', String.escapeSingleQuotes(this.operator))
				.replace('{value}', TEXT_DISPLAY_TYPES.contains(fieldDescribe.getType()) && !operator.contains(':') && this.value != 'null' ?
					this.addQuotes(String.escapeSingleQuotes(this.value)) :
					String.escapeSingleQuotes(this.value));
		}
	}

	// PRIVATE METHOD

	private String fmtDatetime(Datetime dt) {
		return dt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
	}

	private String fmtDate(Datetime dt) {
		return dt.formatGmt('yyyy-MM-dd');
	}

	private String addQuotes(String value) {
		return '\'' + value + '\'';
	}

	private void validateOperator() {
		if (!AVAILABLE_OPERATORS.contains(this.operator.replace(':', ''))) {
			throw new DynamicSOQLConditionException(
				Label.WrongComparisonOperator
				.replace('{operator}', this.operator)
				.replace('{availableOperators}', AVAILABLE_OPERATORS.toString())
			);
		}
	}

	private String stringifyValues(DescribeFieldResult fieldDescribe) {
		String resultTemplate = '({value})';
		if (this.operator.replace(':', '') == 'INCLUDES') {
			return resultTemplate.replace(
				'{value}',
				String.escapeSingleQuotes(String.join(this.values, ';'))
			);
		}
		List<String> quotedValues = new List<String>();
		for (String valueItem : this.values) {
			quotedValues.add(
				TEXT_DISPLAY_TYPES.contains(fieldDescribe.getType()) ?
					this.addQuotes(String.escapeSingleQuotes(valueItem)) :
					String.escapeSingleQuotes(valueItem)
			);
		}
		return resultTemplate.replace('{value}', String.join(quotedValues, ','));
	}

	public class DynamicSOQLConditionException extends Exception{ }
}
