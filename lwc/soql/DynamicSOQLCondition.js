/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
export class DynamicSOQLCondition {
	/**
	 * @type DynamicSOQLFunction
	 */
	function;
	/**
	 * @description Sobject field name. Also it could be a path like Account.Name
	 * @type String
	 */
	fieldName;
	/**
	 * @description SOQL confition operator
	 * @type String
	 */
	operator;
	/**
	 * @description Value of SOQL condition
	 * @type String
	 */
	value;
	/**
	 * @description Array of values that is used for 'IN', 'NOT IN', 'INCLUDES', 'EXCLUDES' operators
	 * @type Array
	 */
	values;

	/**
	 *
	 * @param { String } fieldName
	 * @param { String } operator
	 * @param { Any } value
	 */
	constructor(fieldName, operator, value) {
		this._setFieldNameOrFunction(fieldName);
		this.operator = operator;
		this._setValue(value);
	}

	_setFieldNameOrFunction(fieldName) {
		if (typeof fieldName === 'object' && fieldName !== null) {
			this.function = fieldName;
		} else {
			this.fieldName = fieldName;
		}
	}

	_setValue(value) {
		if (value === null) {
			this.value = 'null';
		} else if (Array.isArray(value)) {
			this.values = value;
		} else {
			this.value = value;
		}
	}
}