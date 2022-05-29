/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
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
		if (this.targetFieldDescribe == null) {
			this.parseFieldPath();
		}
		if (this.targetFieldDescribe.getType() == Schema.DisplayType.ID) {
			return this.path;
		} else if (this.targetFieldDescribe.getType() == Schema.DisplayType.REFERENCE) {
			return (this.path.removeEndIgnoreCase(this.targetFieldDescribe.getName()) +
			this.targetFieldDescribe.getRelationshipName() + '.id').toLowerCase();
		} else {
			return this.path.removeEndIgnoreCase(targetFieldDescribe.getName()) + 'id';
		}
	}

	/**
	 * @description Returns DescribeFieldResult for a target field.
	 * @return   { DescribeFieldResult }
	 */
	public Schema.DescribeFieldResult targetFieldDescribe() {
		if (this.targetFieldDescribe == null) {
			this.parseFieldPath();
		}
		return this.targetFieldDescribe;
	}

	/* PRIVATE METHODS */

	private void parseFieldPath() {
		this.parseFieldPath(this.sObjectType, this.path.split('\\.'));
	}

	private void parseFieldPath(Schema.SObjectType currentType, List<String> path) {
		String fieldApi = path.remove(0);
		if (path.size() > 0) {
			fieldApi = fieldApi.removeEndIgnoreCase('__r') + (fieldApi.endsWithIgnoreCase('__r') ? '__c' : 'id');
			this.targetFieldDescribe = this.targetSobjectDescribe.fields.getMap().get(fieldApi)?.getDescribe();
			if (this.targetFieldDescribe == null) {
				this.throwNoFieldError(fieldApi, this.targetSobjectDescribe.getName());
			}
			this.targetSobjectDescribe = this.targetFieldDescribe.getReferenceTo().get(0).getDescribe();
			this.parseFieldPath(this.targetSobjectDescribe.getSObjectType(), path);
		} else {
			this.targetFieldDescribe = this.targetSobjectDescribe.fields.getMap().get(fieldApi)?.getDescribe();
			if (this.targetFieldDescribe == null) {
				this.throwNoFieldError(fieldApi, this.targetSobjectDescribe.getName());
			}
			List<Schema.SObjectType> referenceToList = this.targetFieldDescribe.getReferenceTo();
			if (referenceToList.size() > 0) {
				this.targetSobjectDescribe = referenceToList[0].getDescribe();
			}
		}
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