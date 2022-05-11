/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
export class DynamicSOQLCondition {
	// String
	fieldName;
	// String
	operator;
	// String
	value;
	// Boolean
	isString;

	/**
	 *
	 * @param { String } fieldName
	 * @param { String } operator
	 * @param { Any } value
	 * @param { Boolean } isString
	 */
	constructor(fieldName, operator, value, isString) {
		this.fieldName = fieldName;
		this.operator = operator;
		this.value = value;
		this.isString = isString === true;
	}
}