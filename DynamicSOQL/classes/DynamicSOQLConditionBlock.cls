/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
public with sharing class DynamicSOQLConditionBlock {
	private final static Set<String> AVAILABLE_OPERATORS = new Set<String>{ 'AND', 'OR' };

	@TestVisible
	private List<DynamicSOQLConditionBlock> blocks;
	@TestVisible
	private List<DynamicSOQLCondition> conditions;
	@TestVisible
	private String operator;

	//CONSTRUCTORS

	public DynamicSOQLConditionBlock(String operator) {
		this.blocks = new List<DynamicSOQLConditionBlock>();
		this.conditions = new List<DynamicSOQLCondition>();
		this.switchOperator(operator);
	}

	//PUBLIC METHODS

	/**
	 * @description Adds condition block
	 * @param  conditionBlock { DynamicSOQLConditionBlock } - new condition block that will be added to the current one.
	 * @return                { DynamicSOQLConditionBlock } - current codition block
	 */
	public DynamicSOQLConditionBlock addConditionBlock(DynamicSOQLConditionBlock conditionBlock) {
		this.blocks.add(conditionBlock);
		return this;
	}

	/**
	 * @description Adds condition block
	 * @param  condition { DynamicSOQLCondition } - new condition that will be added to the current condition block.
	 * @return           { DynamicSOQLConditionBlock } - current codition block
	 */
	public DynamicSOQLConditionBlock addCondition(DynamicSOQLCondition condition) {
		this.conditions.add(condition);
		return this;
	}

	/**
	 * @description Changes the operator. Could be either OR | AND
	 * @param  operator { String } - OR | AND
	 * @return          { DynamicSOQLConditionBlock }
	 */
	public DynamicSOQLConditionBlock switchOperator(String operator) {
		this.operator = operator;
		return this;
	}

	/**
	 * @description Returns all field api names from DynamicSOQLCondition and DynamicSOQLConditionBlock
	 * @return   { Set<String> }
	 */
	public Set<String> fieldsApiNames() {
		Set<String> result = new Set<String>();
		for (DynamicSOQLCondition soqlCondition : this.conditions) {
			result.add(soqlCondition.fieldApiname());
		}
		for (DynamicSOQLConditionBlock conditionBlock : this.blocks) {
			result.addAll(conditionBlock.fieldsApiNames());
		}
		return result;
	}

	/**
	 * @description Builds a Dynamic SOQL Condition Block string for WHERE statement
	 * @return   { String }
	 */
	public override String toString() {
		this.validateBlock();
		List<String> result = new List<String>();

		if (this.blocks != null && !this.blocks.isEmpty()) {
			for (DynamicSOQLConditionBlock block : this.blocks) {
				result.add(block.toString());
			}
		}

		if (this.conditions != null && !this.conditions.isEmpty()) {
			for (DynamicSOQLCondition condition : this.conditions) {
				result.add(condition.toString());
			}
		}
		return '(' + String.join(result, ' ' + this.operator + ' ') + ')';
	}

	private void validateBlock() {
		if (!AVAILABLE_OPERATORS.contains(this.operator)) {
			throw new DynamicSOQLConditionBlockException(
				Label.WrongComparisonOperator
				.replace('{operator}', this.operator)
				.replace('{availableOperators}', AVAILABLE_OPERATORS.toString())
			);
		}
	}

	public class DynamicSOQLConditionBlockException extends Exception { }
}
