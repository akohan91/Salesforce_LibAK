/**
 * @author Andrei Kakhanouski <akohan91@gmail.com>
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
	 * @description DynamicSOQL that is used for 'IN', 'NOT IN' operators like "fieldName IN (SELECT Id FROM Account)"
	 * @type DynamicSOQL
	 */
	soqlValue;

	/**
	 *
	 * @param { String } fieldName
	 * @param { String } operator
	 * @param { Any } value
	 */
	constructor(fieldName, operator, value = 'null') {
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
		if (Array.isArray(value)) {
			this.values = value;
		} else if (value instanceof Date && !isNaN(value)) {
			this.value = value;
		} else if (value === Object(value)) {
			this.soqlValue = value;
		} else if (value === null) {
			this.value = 'null';
		} else {
			this.value = value;
		}
	}
}