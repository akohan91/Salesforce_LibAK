export class DynamicSOQL {
	// String
	sObjectName;
	// DynamicSOQLFunction[]
	selectFunctions = [];
	// String[]
	selectFields = [];
	// DynamicSOQL
	subQueries = {};
	// DynamicSOQLConditionBlock
	conditionBlock;
	// DynamicSOQLGoupBy
	groupBy;
	// DynamicSOQLOrderBy
	orderBy;
	// Integer
	offsetNumber;
	// Integer
	limitNumber;

	/**
	 * @param { String } sObjectName - API name of sObject
	 */
	constructor(sObjectName) {
		this.sObjectName = sObjectName;
	}

	/**
	 * Adds a field to SELECT statement
	 * @param { String } fieldName
	 * @returns { DynamicSOQL }
	 */
	withField(fieldName) {
		this.selectFields.push(fieldName);
		return this;
	}

	/**
	 * Adds a function to SELECT statement like "COUNT(Id) recordsCount"
	 * @param { DynamicSOQLFunction } dynamicSOQLFunction
	 * @returns { DynamicSOQL }
	 */
	withFunction(dynamicSOQLFunction) {
		this.selectFunctions.push(dynamicSOQLFunction);
		return this;
	}

	/**
	 * Adds a subquery
	 * @param { String } - relationship api name of sObject
	 * @param { DynamicSOQL } - DynamicSOQL instance
	 * @returns { DynamicSOQL }
	 */
	withSubQuery(relationshipName, subQuery) {
		this.subQueries[relationshipName] = subQuery;
		return this;
	}

	/**
	 * Adds a condition block to the query
	 * @param { DynamicSOQLConditionBlock } conditionBlock
	 * @returns
	 */
	withCondition(conditionBlock) {
		this.conditionBlock = conditionBlock;
		return this;
	}

	/**
	 * Adds a GROUP BY statement to the query
	 * @param { DynamicSOQLGoupBy } groupBy
	 * @returns { DynamicSOQL }
	 */
	withGroupBy(groupBy) {
		this.groupBy = groupBy;
		return this;
	}

	/**
	 * Adds a ORDER BY statement to the query
	 * @param { DynamicSOQLOrderBy } orderBy
	 * @returns { DynamicSOQL }
	 */
	withOrderBy(orderBy) {
		this.orderBy = orderBy;
		return this;
	}

	/**
	 * Adds OFFSET statement to SOQL
	 * @param { Integer } offsetNumber
	 * @returns { DynamicSOQL }
	 */
	withOffset(offsetNumber) {
		this.offsetNumber = offsetNumber;
		return this;
	}

	/**
	 * Adds LIMIT statement to SOQL
	 * @param { Integer  } limitNumber
	 * @returns { DynamicSOQL }
	 */
	withLimit(limitNumber) {
		this.limitNumber = limitNumber;
		return this;
	}
}