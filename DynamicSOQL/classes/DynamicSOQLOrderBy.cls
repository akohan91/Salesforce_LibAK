/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
public with sharing class DynamicSOQLOrderBy {
	private static final String ORDER_BY_TEMPLATE = 'ORDER BY {fieldOrderByList} {direction} {NULLS}';

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
		this.isDESC         = isDESC;
		this.isNullsFirst  = isNullsFirst;
	}

	// PUBLIC METHODS

	/**
	 * @description Returns ORDER BY statement like: "ORDER BY Name ASC NULLS LAST"
	 * @return   { String }
	 */
	public override String toString() {
		return ORDER_BY_TEMPLATE
			.replace('{fieldOrderByList}', String.join(this.orderByFields, ','))
			.replace('{direction}',        this.isDESC == true ? 'DESC' : 'ASC')
			.replace('{NULLS}',            this.isNullsFirst == true ? 'NULLS FIRST' : 'NULLS LAST');
	}
}
