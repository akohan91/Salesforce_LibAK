/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
public with sharing class DynamicSOQL {
	private final String QUERY_TEMPLATE =
	'SELECT {fields}{subQueries} '+
	'FROM {SObject}' +
	'{WHERE}';
	private DescribeSObjectResult sObjectDescription;
	@TestVisible
	private List<String> subQueries = new List<String>();

	@TestVisible
	protected String sObjectName;
	@TestVisible
	private List<String> fields = new List<String>();
	private DynamicSOQLConditionBlock conditionBlock;

	// CONSTRUCTORS

	/**
	 * @param  sObjectName { String } - API name of sObject
	 * @return             { DynamicSOQL }
	 */
	public DynamicSOQL(String sObjectName) {
		this.sObjectDescription = Schema.getGlobalDescribe().get(sObjectName)?.getDescribe();
		if (this.sObjectDescription == null) {
			throw new DynamicSOQLException(Label.NoSObject.replace('{sObjectName}', sObjectName));
		}
		this.sObjectDescription.getChildRelationships();
		this.sObjectName = this.sObjectDescription.getName();
		if (!this.sObjectDescription.isAccessible()) {
			throw new DynamicSOQLException(Label.sObjectAccessError.replace('{sObjectName}', this.sObjectName));
		}
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
	public DynamicSOQL withSubQuery(DynamicSOQL subQuery) {
		ChildRelationship relation;
		for (ChildRelationship relationItem : this.sObjectDescription.getChildRelationships()) {
			if (String.valueOf(relationItem.getChildSObject()) == subQuery.sObjectName) {
				relation = relationItem;
				break;
			}
		}
		if (relation == null) {
			throw new DynamicSOQLException(
				Label.NoChildSObject
					.replace('{childSObjectName}', subQuery.sObjectName)
					.replace('{sObjectName}', this.sObjectName)
			);
		}

		this.subQueries.add(
			'(' +
			subQuery.toString().replace(
				'FROM ' + subQuery.sObjectName,
				'FROM ' + relation.getRelationshipName()
			) +
			')'
		);
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
		List<String> flsErrors = this.checkFieldAccessibility(this.fields);
		if (!flsErrors.isEmpty()) {
			throw new DynamicSOQLException(String.join(flsErrors, ' '));
		}

		return this.QUERY_TEMPLATE
			.replace('{fields}', String.join(this.fields, ','))
			.replace('{subQueries}', (!this.subQueries.isEmpty() ? ',' + String.join(this.subQueries, ',') : ''))
			.replace('{SObject}', this.sObjectName)
			.replace('{WHERE}', (this.conditionBlock != null ? ' WHERE ' + this.conditionBlock.toString() : ''));
	}

	/* PRIVATE METHODS */

	/**
	 * @description Checks the FLS for list of fields
	 * @return   { String[] } - List of FLS errors
	 */
	private List<String> checkFieldAccessibility(List<String> fieldsToFlsCheck) {
		List<String> errors = new List<String>();
		Map<String, SObjectField> fieldsDescribeMap = this.sObjectDescription.fields.getMap();
		for (String fieldName : fieldsToFlsCheck) {
			if(!fieldsDescribeMap.get(fieldName).getDescribe().isAccessible()) {
				errors.add(Label.FieldAccessError
					.replace('{fieldName}', fieldName)
					.replace('{sObjectName}', this.sObjectName)
				);
			}
		}
		return errors;
	}

	public class DynamicSOQLException extends Exception {}
}
