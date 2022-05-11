export class DynamicSOQLGoupBy {
	// String[]
	fieldGroupByList = [];
	// DynamicSOQLConditionBlock
	conditionBlock;

	/**
	 * @param { String[] } fieldGroupByList
	 */
	constructor(fieldGroupByList) {
		if (!Array.isArray(fieldGroupByList)) {
			throw new Error('The "fieldGroupByList" parameter should be a String[].');
		}
		this.fieldGroupByList = fieldGroupByList;
	}

	/**
	 * Adds HAVING clause to the GROUP BY clause
	 * @param { DynamicSOQLConditionBlock } conditionBlock
	 */
	withHaving(conditionBlock) {
		this.conditionBlock = conditionBlock;
		return this;
	}
}