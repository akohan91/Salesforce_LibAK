/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
public with sharing class DynamicSOQLCondition {
	private DynamicSOQLFunction function;
	private String fieldName;
	private String operator;
	private String value;
	private List<String> values;
	private DynamicSOQL soqlValue;

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
		this.value = value == null ? DynamicSOQLConstants.NULL_STRING : value;
	}

	public DynamicSOQLCondition(String fieldName, String operator, List<String> values) {
		this(fieldName, operator);
		this.values = values;
	}

	public DynamicSOQLCondition(String fieldName, String operator, DynamicSOQL soqlValue) {
		this(fieldName, operator);
		this.soqlValue = soqlValue;
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
		DescribeFieldResult fieldDescribe = new SobjectFieldPath(sobjectApiName, this.fieldApiName()).targetFieldDescribe();
		this.validateOperator();
		if (this.function != null) {
			return DynamicSOQLConstants.TMPL_CONDITION
				.replace(DynamicSOQLConstants.PH_LEFT_PART, this.function.stringify())
				.replace(DynamicSOQLConstants.PH_OPERATOR, String.escapeSingleQuotes(this.operator))
				.replace(DynamicSOQLConstants.PH_RIGHT_PART, String.escapeSingleQuotes(this.value));
		} else if (this.values != null) {
			return DynamicSOQLConstants.TMPL_CONDITION
				.replace(DynamicSOQLConstants.PH_LEFT_PART, String.escapeSingleQuotes(this.fieldName))
				.replace(DynamicSOQLConstants.PH_OPERATOR, String.escapeSingleQuotes(this.operator))
				.replace(DynamicSOQLConstants.PH_RIGHT_PART, this.stringifyValues(fieldDescribe));
		}  else if (this.soqlValue != null) {
			return DynamicSOQLConstants.TMPL_CONDITION
				.replace(DynamicSOQLConstants.PH_LEFT_PART, String.escapeSingleQuotes(this.fieldName))
				.replace(DynamicSOQLConstants.PH_OPERATOR, String.escapeSingleQuotes(this.operator))
				.replace(DynamicSOQLConstants.PH_RIGHT_PART, '(' + this.soqlValue.stringify() + ')');
		} else {
			return DynamicSOQLConstants.TMPL_CONDITION
				.replace(DynamicSOQLConstants.PH_LEFT_PART, String.escapeSingleQuotes(this.fieldName))
				.replace(DynamicSOQLConstants.PH_OPERATOR, String.escapeSingleQuotes(this.operator))
				.replace(DynamicSOQLConstants.PH_RIGHT_PART, this.processValue(this.value, fieldDescribe));
		}
	}

	// PRIVATE METHOD

	private String fmtDatetime(Datetime dt) {
		return dt.formatGmt(DynamicSOQLConstants.FORMAT_DATE_TIME);
	}

	private String fmtDate(Datetime dt) {
		return dt.formatGmt(DynamicSOQLConstants.FORMAT_DATE);
	}

	private String processValue(String value, DescribeFieldResult fieldDescribe) {
		if (DynamicSOQLConstants.TEXT_DISPLAY_TYPES.contains(fieldDescribe.getType())
			&& !operator.contains(DynamicSOQLConstants.COLON)
			&& value != DynamicSOQLConstants.NULL_STRING
		) {
			return this.addQuotes(String.escapeSingleQuotes(value));
		} else if (fieldDescribe.getType() == Schema.DisplayType.Date) {
			return String.escapeSingleQuotes(value).substringBefore(DynamicSOQLConstants.FORMAT_TIME_SEPARATOR);
		} else {
			return String.escapeSingleQuotes(value);
		}
	}

	private String addQuotes(String value) {
		return DynamicSOQLConstants.SINGLE_QUOTE + value + DynamicSOQLConstants.SINGLE_QUOTE;
	}

	private void validateOperator() {
		String operator = this.operator.replace(DynamicSOQLConstants.COLON, DynamicSOQLConstants.EMPTY_STRING);
		if (!DynamicSOQLConstants.CONDITION_AVAILABLE_OPERATORS.contains(operator)) {
			throw new DynamicSOQLConditionException(
				Label.WrongComparisonOperator
				.replace(DynamicSOQLConstants.PH_OPERATOR, this.operator)
				.replace(
					DynamicSOQLConstants.PH_AVAILABLE_OPERATORS,
					DynamicSOQLConstants.CONDITION_AVAILABLE_OPERATORS.toString()
				)
			);
		}
	}

	private String stringifyValues(DescribeFieldResult fieldDescribe) {
		String operator = this.operator.replace(DynamicSOQLConstants.COLON, DynamicSOQLConstants.EMPTY_STRING);
		if (operator == DynamicSOQLConstants.OPERATOR_INCLUDES || operator == DynamicSOQLConstants.OPERATOR_EXCLUDES) {
			return DynamicSOQLConstants.TMPL_BULK_VALUES.replace(
				DynamicSOQLConstants.PH_BULK_VALUES,
				String.escapeSingleQuotes(String.join(this.values, DynamicSOQLConstants.SEMICOLON))
			);
		}
		List<String> quotedValues = new List<String>();
		for (String valueItem : this.values) {
			quotedValues.add(this.processValue(valueItem, fieldDescribe));
		}
		return DynamicSOQLConstants.TMPL_BULK_VALUES.replace(
			DynamicSOQLConstants.PH_BULK_VALUES,
			String.join(quotedValues, DynamicSOQLConstants.COMMA)
		);
	}

	public class DynamicSOQLConditionException extends Exception{ }
}
