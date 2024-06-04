/**
 * @author Andrei Kakhanouski <akohan91@gmail.com>
 */
public with sharing class DynamicSOQLGroupBy {
	@TestVisible
	private List<String> fieldGroupByList;
	private DynamicSOQLConditionBlock conditionBlock;

	public DynamicSOQLGroupBy(List<String> fieldGroupByList) {
		this.fieldGroupByList = fieldGroupByList;
	}

	/**
	 * @description Adds HAVING clause to the GROUP BY clause
	 * @param  conditionBlock { DynamicSOQLConditionBlock }
	 * @return                { DynamicSOQLGoupBy }
	 */
	public DynamicSOQLGroupBy withHaving(DynamicSOQLConditionBlock conditionBlock) {
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
	 * @description Builds a GROUP BY part of SOQL string
	 * @param  sobjectApiName { String } Sobject api name for what the group by is created.
	 * @return   { String }
	 */
	public String stringify(String sobjectApiName) {
		return DynamicSOQLConstants.TMPL_GROUP_BY
			.replace(
				DynamicSOQLConstants.PH_FIELD_GROUP_BY_LIST,
				String.escapeSingleQuotes(String.join(this.fieldGroupByList, DynamicSOQLConstants.COMMA))
			).replace(
				DynamicSOQLConstants.PH_HAVING,
				this.conditionBlock != null ? ' HAVING ' + this.conditionBlock.stringify(sobjectApiName) : DynamicSOQLConstants.EMPTY_STRING
			)
		;
	}
}
