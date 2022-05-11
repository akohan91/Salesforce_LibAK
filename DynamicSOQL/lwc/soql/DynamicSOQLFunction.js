export class DynamicSOQLFunction {
	// String
	functionName;
	// String
	fieldName;
	// String
	alias;

	/**
	 * @param { String } functionName
	 * @param { String } fieldName
	 * @param { String } alias
	 */
	constructor(functionName, fieldName, alias) {
		this.functionName = functionName;
		this.fieldName = fieldName;
		this.alias = alias;
	}
}