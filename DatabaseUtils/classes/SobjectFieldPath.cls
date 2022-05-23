/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
public with sharing class SobjectFieldPath implements SobjectFieldPathInterface {
	private SObjectType sObjectType;
	private String path;
	private DescribeSObjectResult targetSobjectDescribe;
	private DescribeFieldResult targetFieldDescribe;

	/* CONSTRUCTORS */

	public SobjectFieldPath(String sobjectApi, String path) {
		this(Schema.getGlobalDescribe().get(sobjectApi), path);
	}

	public SobjectFieldPath(SObjectType sObjectType, String path) {
		this.sObjectType = sObjectType;
		this.targetSobjectDescribe = sObjectType.getDescribe();
		this.path = path;
	}

	/* PUBLIC METHODS */

	public String path() {
		return this.path;
	}

	public String targetReferencePath() {
		if (this.targetFieldDescribe == null) {
			this.parseFieldPath();
		}
		if (this.targetFieldDescribe.getType() == Schema.DisplayType.ID) {
			return this.path;
		} else if (this.targetFieldDescribe.getType() == Schema.DisplayType.REFERENCE) {
			if (this.path.endsWithIgnoreCase('id')) {
				return this.path.removeEndIgnoreCase('id') + '.id';
			} else {
				return this.path.removeEndIgnoreCase('__c') + '__r.id';
			}
		} else {
			return this.path.removeEndIgnoreCase(targetFieldDescribe.getName()) + 'id';
		}
	}

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
			fieldApi = fieldApi.removeEnd('__r') + (fieldApi.endsWithIgnoreCase('__r') ? '__c' : 'id');
			this.targetFieldDescribe = this.targetSobjectDescribe.fields.getMap().get(fieldApi).getDescribe();
			this.targetSobjectDescribe = this.targetFieldDescribe.getReferenceTo().get(0).getDescribe();
			this.parseFieldPath(this.targetSobjectDescribe.getSObjectType(), path);
		} else {
			this.targetFieldDescribe = this.targetSobjectDescribe.fields.getMap().get(fieldApi).getDescribe();
			List<Schema.SObjectType> referenceToList = this.targetFieldDescribe.getReferenceTo();
			if (referenceToList.size() > 0) {
				this.targetSobjectDescribe = referenceToList[0].getDescribe();
			}
		}
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