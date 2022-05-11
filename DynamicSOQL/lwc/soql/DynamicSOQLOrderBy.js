/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
export class DynamicSOQLOrderBy {
	// String[]
	orderByFields = [];
	// Boolean
	isDESC = false;
	// Boolean
	isNullsFirst = false;

	/**
	 *
	 * @param { String[] } orderByFields
	 * @param { Boolean } isDESC
	 * @param { Boolean } isNullsFirst
	 */
	constructor(orderByFields, isDESC, isNullsFirst) {
		if (!Array.isArray(orderByFields)) {
			throw new Error('The "orderByFields" parameter should be a String[].');
		}
		this.orderByFields = orderByFields;
		this.isDESC = isDESC === true;
		this.isNullsFirst = isNullsFirst === true;
	}
}