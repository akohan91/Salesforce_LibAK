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
	private DynamicSOQLFunction function;
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
		this.isString = operator.contains(':') || this.value == 'null' ? false : true;
	}

	private DynamicSOQLCondition(String fieldName, String operator) {
		this.fieldName = fieldName;
		this.operator = operator;
	}

	// PUBLIC METHOD

	public String fieldApiName() {
		if (this.fieldName != null) {
			return this.fieldName;
		} else if (this.function != null) {
			return this.function.fieldApiName();
		} else {
			throw new DynamicSOQLConditionException(Label.NoFieldApiNameInSOQLCondition);
		}
	}

	public override String toString() {
		this.validateCondition();
		String leftPart = this.fieldName != null ? this.fieldName : this.function.toString();
		return '{fieldName} {operator} {value}'
			.replace('{fieldName}', String.escapeSingleQuotes(leftPart))
			.replace('{operator}', String.escapeSingleQuotes(this.operator))
			.replace(
				'{value}', this.isString == true ?
				this.addQuotes(String.escapeSingleQuotes(this.value)) :
				String.escapeSingleQuotes(this.value)
			);
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
