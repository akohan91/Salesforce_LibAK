/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
public with sharing class DynamicSOQLOrderBy {
	private List<String> orderByFields;
	private Boolean isDESC;
	private Boolean isNullsFirst;

	// CONSTRUCTORS

	public DynamicSOQLOrderBy(List<String> orderByFields) {
		this(orderByFields, false, false);
	}

	public DynamicSOQLOrderBy(List<String> orderByFields, Boolean isDESC) {
		this(orderByFields, isDESC, false);
	}

	public DynamicSOQLOrderBy(List<String> orderByFields, Boolean isDESC, Boolean isNullsFirst) {
		this.orderByFields = orderByFields;
		this.isDESC        = isDESC;
		this.isNullsFirst  = isNullsFirst;
	}

	// PUBLIC METHODS

	/**
	 * @description Returns list of fields that are used in ORDER BY Statement
	 * @return   { List<String> }
	 */
	public List<String> fieldsApiNames() {
		return this.orderByFields.clone();
	}

	/**
	 * @description Returns ORDER BY statement like: "ORDER BY Name ASC NULLS LAST"
	 * @return   { String }
	 */
	public String stringify() {
		return DynamicSOQLConstants.TMPL_ORDER_BY
			.replace(
				DynamicSOQLConstants.PH_FIELD_ORDER_BY_LIST,
				String.escapeSingleQuotes(String.join(this.orderByFields, DynamicSOQLConstants.COMMA))
			).replace(
				DynamicSOQLConstants.PH_DIRECTION,
				this.isDESC == true ? DynamicSOQLConstants.SORT_DIRECTION_DESC : DynamicSOQLConstants.SORT_DIRECTION_ASC
			).replace(
				DynamicSOQLConstants.PH_NULLS,
				this.isNullsFirst == true ? DynamicSOQLConstants.NULLS_FIRST : DynamicSOQLConstants.NULLS_LAST
			);
	}
}
