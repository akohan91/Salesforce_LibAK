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
	@TestVisible
	private String fieldName;
	@TestVisible
	private String operator;
	@TestVisible
	private String value;
	@TestVisible
	private Boolean isString;

	// CONSTRUCTORS

	public DynamicSOQLCondition(String fieldName, String operator, Object value) {
		this(fieldName, operator);
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
		this.value = String.escapeSingleQuotes(value);
		this.isString = operator.contains(':') ? false : true;
	}

	private DynamicSOQLCondition(String fieldName, String operator) {
		this.fieldName = String.escapeSingleQuotes(fieldName);
		this.operator = String.escapeSingleQuotes(operator);
	}

	// PUBLIC METHOD

	public override String toString() {
		this.validateCondition();
		return '{fieldName} {operator} {value}'
			.replace('{fieldName}', this.fieldName)
			.replace('{operator}', this.operator)
			.replace('{value}', this.isString == true ? this.addQuotes(this.value) : this.value);
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

	private void validateCondition() {
		if (!AVAILABLE_OPERATORS.contains(this.operator.replace(':', ''))) {
			throw new DynamicSOQLConditionException(
				Label.WrongComparisonOperator
				.replace('{operator}', this.operator)
				.replace('{availableOperators}', AVAILABLE_OPERATORS.toString())
			);
		}
	}

	public class DynamicSOQLConditionException extends Exception{ }
}
