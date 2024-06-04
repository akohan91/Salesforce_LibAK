/**
 * @author Andrei Kakhanouski <akohan91@gmail.com>
 */
export class DynamicSOQLConditionBlock {
	// DynamicSOQLConditionBlock[]
	blocks = [];
	// DynamicSOQLCondition[]
	conditions = [];
	// String
	operator;

	constructor(operator) {
		this.operator = operator;
	}

	/**
	 * Adds new condition block that will be added to the current one.
	 * It allow to build complex conditions like `(condition OR condition) AND condition`
	 * @param { DynamicSOQLConditionBlock } conditionBlock
	 */
	addConditionBlock(conditionBlock) {
		this.blocks.push(conditionBlock);
		return this;
	}

	/**
	 * Adds the DynamicSOQLCondition instance to the current block
	 * @param { DynamicSOQLCondition } condition
	 */
	addCondition(condition) {
		this.conditions.push(condition);
		return this;
	}

	/**
	 * Changes the operator. Could be either OR | AND
	 * @param { String } operator
	 */
	switchOperator(operator) {
		this.operator = operator;
		return this;
	}
}