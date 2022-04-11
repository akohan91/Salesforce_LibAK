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
		this.value =  value;
		this.isString = true;
	}

	private DynamicSOQLCondition(String fieldName, String operator) {
		if (!AVAILABLE_OPERATORS.contains(operator)) {
			throw new DynamicSOQLConditionException(
				Label.WrongComparisonOperator
				.replace('{operator}', operator)
				.replace('{availableOperators}', AVAILABLE_OPERATORS.toString())
			);
		}
		this.fieldName = String.escapeSingleQuotes(fieldName);
		this.operator = String.escapeSingleQuotes(operator);
	}

	// PUBLIC METHOD

	public override String toString() {
		return '{fieldName} {operator} {value}'
			.replace('{fieldName}', this.fieldName)
			.replace('{operator}', this.operator)
			.replace('{value}', this.isString == true ? this.escapeSingleQuotes(this.value) : this.value);
	}

	// PRIVATE METHOD

	private String fmtDatetime(Datetime dt) {
		return dt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
	}

	private String fmtDate(Datetime dt) {
		return dt.formatGmt('yyyy-MM-dd');
	}

	private String escapeSingleQuotes(String value) {
		return '\'' + String.escapeSingleQuotes(value) + '\'';
	}

	public class DynamicSOQLConditionException extends Exception{ }
}
