/**
 * @author Andrei Kakhanouski <akohan91@gmail.com>
 * Represent field path of sobject.
 * Example: For Contact sobject: Account.Name
 */
public with sharing class SobjectFieldPath implements SobjectFieldPathInterface {
	public static Map<String,Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
	@TestVisible
	private SObjectType sObjectType;
	private String path;
	@TestVisible
	private DescribeSObjectResult targetSobjectDescribe;
	private DescribeFieldResult targetFieldDescribe;

	/* CONSTRUCTORS */

	/**
	 * @param  sobjectApi { String } - Sobject API Name
	 * @param  path       { String } - field path. Example: Account.Name
	 * @return            { SobjectFieldPath }
	 */
	public SobjectFieldPath(String sobjectApi, String path) {
		if (globalDescribe.get(sobjectApi) == null) {
			this.throwNoSobjectError(sobjectApi);
		} else {
			this(globalDescribe.get(sobjectApi), path);
		}
	}

	/**
	 * @param  sobjectApi { SObjectType }
	 * @param  path       { String }      - field path. Example: Account.Name
	 * @return            { SobjectFieldPath }
	 */
	public SobjectFieldPath(SObjectType sObjectType, String path) {
		this.sObjectType = sObjectType;
		this.targetSobjectDescribe = sObjectType.getDescribe();
		this.path = path.toLowerCase();
	}

	/* PUBLIC METHODS */

	/**
	 * @description Returns field path. Example: Account.Name
	 * @return   { String }
	 */
	public String path() {
		return this.path;
	}

	/**
	 * @description Returns reference path for target sobject
	 * if sobject is 'Contact' and path is 'account.name' it returns 'account.id'
	 * @return   { String }
	 */
	public String targetReferencePath() {
		this.parseFieldPath();
		switch on this.targetFieldDescribe.getType() {
			when ID {
				return this.path;
			}
			when REFERENCE {
				return (this.path.removeEndIgnoreCase(this.targetFieldDescribe.getName()) +
					this.targetFieldDescribe.getRelationshipName() + '.id').toLowerCase();
			}
			when else {
				return this.path.removeEndIgnoreCase(targetFieldDescribe.getName()) + 'id';
			}
		}
	}

	/**
	 * @description Returns DescribeFieldResult for a target field.
	 * @return   { DescribeFieldResult }
	 */
	public Schema.DescribeFieldResult targetFieldDescribe() {
		this.parseFieldPath();
		return this.targetFieldDescribe;
	}

	/* PRIVATE METHODS */

	private void parseFieldPath() {
		if (this.targetFieldDescribe == null) {
			this.parseFieldPath(this.sObjectType, this.path.split('\\.'));
		}
	}

	private void parseFieldPath(Schema.SObjectType currentType, List<String> path) {
		String pathItem = path.remove(0);
		if (path.size() > 0) {
			this.targetSobjectDescribe = this.relationFieldSobjectDescribe(
				this.convertRelationPathItemToTargetFieldApi(pathItem),
				this.targetSobjectDescribe
			);
			this.parseFieldPath(this.targetSobjectDescribe.getSObjectType(), path);
		} else {
			this.targetFieldDescribe = this.targetSobjectDescribe.fields.getMap().get(pathItem)?.getDescribe();
			if (this.targetFieldDescribe == null) {
				this.throwNoFieldError(pathItem, this.targetSobjectDescribe.getName());
			}
			List<Schema.SObjectType> referenceToList = this.targetFieldDescribe.getReferenceTo();
			if (referenceToList.size() > 0) {
				this.targetSobjectDescribe = referenceToList[0].getDescribe();
			}
		}
	}

	private String convertRelationPathItemToTargetFieldApi(String relationPathItem) {
		return relationPathItem.removeEndIgnoreCase('__r') + (relationPathItem.endsWithIgnoreCase('__r') ? '__c' : 'id');
	}

	private Schema.DescribeSObjectResult relationFieldSobjectDescribe(String relationFieldApi, Schema.DescribeSObjectResult sobjectDescribe) {
		Schema.DescribeFieldResult fieldDescribe = sobjectDescribe.fields.getMap().get(relationFieldApi)?.getDescribe();
		if (fieldDescribe == null) {
			this.throwNoFieldError(relationFieldApi, sobjectDescribe.getName());
		}
		return fieldDescribe.getReferenceTo().get(0).getDescribe();
	}

	private void throwNoSobjectError(String sobjectName) {
		throw new SobjectFieldPathException(
			Label.NoSobjectTemplate
			.replace('{sobject}', sobjectName)
		);
	}

	private void throwNoFieldError(String fieldName, String sobjectName) {
		throw new SobjectFieldPathException(
			Label.NoSobjectFieldTemplate
			.replace('{pathItem}', fieldName)
			.replace('{sobject}', sobjectName)
		);
	}

	public class SobjectFieldPathException extends Exception {}
}