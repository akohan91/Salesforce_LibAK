/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
public with sharing class SobjectFieldPath implements SobjectFieldPathInterface{
	private SObjectType sObjectType;
	private String path;

	public SobjectFieldPath(String sobjectApi, String path) {
		this(Schema.getGlobalDescribe().get(sobjectApi), path);
	}

	public SobjectFieldPath(SObjectType sObjectType, String path) {
		this.sObjectType = sObjectType;
		this.path = path;
	}

	public Schema.DescribeFieldResult targetFieldDescribe() {
		SObjectType tempSobjectType = this.sObjectType;
		List<String> pathItems = path.replaceAll('toLabel\\(', '').replaceAll('\\)', '').split('\\.');

		SObjectField sobjectPathFieldItem;
		while (pathItems.size() > 1) {
			String pathItem = pathItems.remove(0);
			if (pathItem.endsWith('__r')) {
				pathItem = pathItem.removeEnd('__r') + '__c';
			} else {
				pathItem += 'id';
			}

			sobjectPathFieldItem = tempSobjectType.getDescribe().fields.getMap().get(pathItem);
			if (sobjectPathFieldItem == null) {
				this.throwNoFieldError(pathItem, String.valueOf(tempSobjectType));
			}
			tempSobjectType = sobjectPathFieldItem?.getDescribe().getReferenceTo().get(0);
		}

		String pathItem = pathItems.remove(0);
		sobjectPathFieldItem = tempSobjectType.getDescribe().fields.getMap().get(pathItem);
		if (sobjectPathFieldItem == null) {
			this.throwNoFieldError(pathItem, String.valueOf(tempSobjectType));
		}

		return sobjectPathFieldItem.getDescribe();
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
