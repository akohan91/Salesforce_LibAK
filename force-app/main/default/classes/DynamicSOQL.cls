/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
public with sharing class DynamicSOQL {
	private final static String QUERY_TEMPLATE =
	'SELECT {fields}{subQueries} '+
	'FROM {SObject}' +
	'{WHERE}';

	@TestVisible
	private String sObjectName;
	@TestVisible
	private List<String> fields = new List<String>();
	@TestVisible
	private Map<String, DynamicSOQL> subQueries = new Map<String, DynamicSOQL>();
	private DynamicSOQLConditionBlock conditionBlock;

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
	 * @param  subQuery { DynamicSOQL } - DynamicSOQL instance
	 * @return          { DynamicSOQL }
	 */
	public DynamicSOQL withSubQuery(String relationshipName, DynamicSOQL subQuery) {
		this.subQueries.put(relationshipName, subQuery);
		return this;
	}

	public DynamicSOQL withConditions(DynamicSOQLConditionBlock conditionBlock) {
		this.conditionBlock = conditionBlock;
		return this;
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
			.replace('{fields}', String.join(this.fields, ','))
			.replace('{subQueries}', (!subQueriesString.isEmpty() ? ',' + String.join(subQueriesString, ',') : ''))
			.replace('{SObject}', this.sObjectName)
			.replace('{WHERE}', (this.conditionBlock != null ? ' WHERE ' + this.conditionBlock.toString() : ''));
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
