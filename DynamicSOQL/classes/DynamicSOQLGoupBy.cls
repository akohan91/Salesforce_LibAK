/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
public with sharing class DynamicSOQLGoupBy {
	private static final String GROUP_BY_TEMPLATE = 'GROUP BY {fieldGroupByList}{HAVING}';

	@TestVisible
	private List<String> fieldGroupByList;
	private DynamicSOQLConditionBlock conditionBlock;

	public DynamicSOQLGoupBy(List<String> fieldGroupByList) {
		this.fieldGroupByList = fieldGroupByList;
	}

	/**
	 * @description Adds HAVING clause to the GROUP BY clause
	 * @param  conditionBlock { DynamicSOQLConditionBlock }
	 * @return                { DynamicSOQLGoupBy }
	 */
	public DynamicSOQLGoupBy withHaving(DynamicSOQLConditionBlock conditionBlock) {
		this.conditionBlock = conditionBlock;
		return this;
	}

	/**
	 * @description Returns list of fields that are used in GROUP BY Statement
	 * @return   { List<String> }
	 */
	public List<String> fieldsApiNames() {
		return this.fieldGroupByList.clone();
	}

	/**
	 * @description Builds a SOQL string
	 * @return   { String }
	 */
	public override String toString() {
		return GROUP_BY_TEMPLATE
			.replace('{fieldGroupByList}', String.join(this.fieldGroupByList, ','))
			.replace('{HAVING}', this.conditionBlock != null ? ' HAVING ' + this.conditionBlock.toString() : '')
		;
	}
}
