/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
public with sharing class DynamicSOQL {
	private final static String QUERY_TEMPLATE =
	'SELECT {fields}{subQueries} '+
	'FROM {SObject}' +
	'{WHERE}' +
	'{GROUP BY}' +
	'{ORDER BY}' +
	'{LIMIT}' +
	'{OFFSET}';

	@TestVisible
	private String sObjectName;
	@TestVisible
	private List<String> fields = new List<String>();
	@TestVisible
	private Map<String, DynamicSOQL> subQueries = new Map<String, DynamicSOQL>();
	private DynamicSOQLConditionBlock conditionBlock;
	DynamicSOQLGoupBy groupBy;
	DynamicSOQLOrderBy orderBy;
	private Integer offsetNumber;
	private Integer limitNumber;

	// CONSTRUCTORS

	/**
	 * @param  sObjectName { String } - API name of sObject
	 * @return             { DynamicSOQL }
	 */
	public DynamicSOQL(String sObjectName) {
		this.sObjectName = sObjectName;
	}

	/* PUBLIC METHODS */

	/**
	 * @description Adds a field to SELECT statement
	 * @param  fieldName { String } - API field name
	 * @return           { DynamicSOQL }
	 */
	public DynamicSOQL withField(String fieldName) {
		this.fields.add(fieldName);
		return this;
	}

	/**
	 * @description Adds a subquery
	 * @param  relationshipName { String } - relationship api name of sObject
	 * @param  subQuery         { DynamicSOQL } - DynamicSOQL instance
	 * @return                  { DynamicSOQL }
	 */
	public DynamicSOQL withSubQuery(String relationshipName, DynamicSOQL subQuery) {
		this.subQueries.put(relationshipName, subQuery);
		return this;
	}

	/**
	 * @description Adds a condition block to the query
	 * @param  conditionBlock { DynamicSOQLConditionBlock }
	 * @return                { DynamicSOQL }
	 */
	public DynamicSOQL withConditions(DynamicSOQLConditionBlock conditionBlock) {
		this.conditionBlock = conditionBlock;
		return this;
	}

	public DynamicSOQL withGroupBy(DynamicSOQLGoupBy groupBy) {
		this.groupBy = groupBy;
		return this;
	}

	/**
	 * @description Adds a ORDER BY statement to the query
	 * @param  orderBy orderBy description
	 * @return         return description
	 */
	public DynamicSOQL withOrderBy(DynamicSOQLOrderBy orderBy) {
		this.orderBy = orderBy;
		return this;
	}

	/**
	 * @description Adds OFFSET statement to SOQL
	 * @param  offsetNumber { Integer }
	 * @return              { DynamicSOQL }
	 */
	public DynamicSOQL withOffset(Integer offsetNumber) {
		this.offsetNumber = offsetNumber;
		return this;
	}

	/**
	 * @description Adds LIMIT statement to SOQL
	 * @param  limitNumber { Integer }
	 * @return             { DynamicSOQL }
	 */
	public DynamicSOQL withLimit(Integer limitNumber) {
		this.limitNumber = limitNumber;
		return this;
	}

	/**
	 * @description Returns the Map in format: sObjectApiName => Set<String>{fieldApiName}
	 * @return   { Map<String, Set<String>> }
	 */
	public Map<String, Set<String>> infoToFLSCheck() {
		Map<String, Set<String>> result = new Map<String, Set<String>>();
		result.put(this.sObjectName, new Set<String>(this.fields));
		if (this.conditionBlock != null) {
			result.get(this.sObjectName).addAll(this.conditionBlock.fieldsApiNames());
		}
		if (this.subQueries != null && !this.subQueries.isEmpty()) {
			for (DynamicSOQL subQuery : this.subQueries.values()) {
				result.putAll(subQuery.infoToFLSCheck());
			}
		}
		if (this.orderBy != null) {
			result.get(this.sObjectName).addAll(this.orderBy.fieldsList());
		}
		return result;
	}

	/**
	 * @description Builds a SOQL string
	 * @return   { String }
	 */
	public override String toString() {
		DescribeSObjectResult sObjectDescription = Schema.getGlobalDescribe().get(sObjectName)?.getDescribe();
		if (sObjectDescription == null) {
			throw new DynamicSOQLException(Label.NoSObject.replace('{sObjectName}', sObjectName));
		}
		List<String> subQueriesString = this.buidSubqueries(sObjectDescription);

		return QUERY_TEMPLATE
			.replace('{fields}',     String.join(this.fields, ','))
			.replace('{subQueries}', !subQueriesString.isEmpty() ? ',' + String.join(subQueriesString, ',') : '')
			.replace('{SObject}',    this.sObjectName)
			.replace('{WHERE}',      this.conditionBlock != null ? ' WHERE '  + this.conditionBlock.toString() : '')
			.replace('{GROUP BY}',   this.groupBy        != null ? ' ' + this.groupBy.toString() : '')
			.replace('{ORDER BY}',   this.orderBy        != null ? ' ' + this.orderBy.toString() : '')
			.replace('{LIMIT}',      this.limitNumber    != null ? ' LIMIT '  + this.limitNumber : '' )
			.replace('{OFFSET}',     this.offsetNumber   != null ? ' OFFSET ' + this.offsetNumber : '' );
	}

	/* PRIVATE METHODS */

	private List<String> buidSubqueries(DescribeSObjectResult sObjectDescription) {
		if (this.subQueries == null || this.subQueries.isEmpty()) {
			return new List<String>();
		}

		List<String> result = new List<String>();

		Set<String> sObjectRelationsNames = new Set<String>();
		for (ChildRelationship relationItem : sObjectDescription.getChildRelationships()) {
			sObjectRelationsNames.add(relationItem.getRelationshipName());
		}

		for (String childRelationName : this.subQueries.keySet()) {
			DynamicSOQL subQuery = this.subQueries.get(childRelationName);
			if (!sObjectRelationsNames.contains(childRelationName)) {
				throw new DynamicSOQLException(
					Label.NoChildSObject
						.replace('{childSObjectName}', subQuery.sObjectName)
						.replace('{sObjectName}', this.sObjectName)
				);
			}
			result.add('(' + subQuery.toString().replace(
				'FROM ' + subQuery.sObjectName,
				'FROM ' + childRelationName
			) + ')');
		}
		return result;
	}

	public class DynamicSOQLException extends Exception {}
}
