/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
public with sharing class DynamicSOQLConditionBlock {
	private List<DynamicSOQLConditionBlock> blocks;
	private List<DynamicSOQLCondition> conditions;
	private String operator;

	// CONSTRUCTORS

	public DynamicSOQLConditionBlock(String operator) {
		this.blocks = new List<DynamicSOQLConditionBlock>();
		this.conditions = new List<DynamicSOQLCondition>();
		this.switchOperator(operator);
	}

	// PUBLIC METHODS

	/**
	 * @description Adds new condition block that will be added to the current one.
	 *              It allow to build complex conditions like `(condition OR condition) AND condition`
	 * @param  conditionBlock { DynamicSOQLConditionBlock } - new condition block that will be added to the current one.
	 * @return                { DynamicSOQLConditionBlock } - current codition block
	 */
	public DynamicSOQLConditionBlock addConditionBlock(DynamicSOQLConditionBlock conditionBlock) {
		this.blocks.add(conditionBlock);
		return this;
	}

	/**
	 * @description Adds a condition to the current block
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
	 * @param sobjectApiName { String } Sobject api name for what the condition block is created.
	 * @return   { String }
	 */
	public String stringify(String sobjectApiName) {
		this.operator = String.escapeSingleQuotes(this.operator);
		this.validateBlock();
		List<String> result = new List<String>();

		if (this.blocks != null && !this.blocks.isEmpty()) {
			for (DynamicSOQLConditionBlock block : this.blocks) {
				result.add(block.stringify(sobjectApiName));
			}
		}

		if (this.conditions != null && !this.conditions.isEmpty()) {
			for (DynamicSOQLCondition condition : this.conditions) {
				result.add(condition.stringify(sobjectApiName));
			}
		}
		return '(' + String.join(result, ' ' + this.operator + ' ') + ')';
	}

	// PRIVATE METHODS

	private void validateBlock() {
		if (!DynamicSOQLConstants.CONDITION_BLOCK_AVAILABLE_OPERATORS.contains(this.operator)) {
			throw new DynamicSOQLConditionBlockException(
				Label.WrongComparisonOperator
				.replace(DynamicSOQLConstants.PH_OPERATOR, this.operator)
				.replace(
					DynamicSOQLConstants.PH_AVAILABLE_OPERATORS,
					DynamicSOQLConstants.CONDITION_BLOCK_AVAILABLE_OPERATORS.toString())
			);
		}
	}

	public class DynamicSOQLConditionBlockException extends Exception { }
}
