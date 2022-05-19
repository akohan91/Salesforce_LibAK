/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
public with sharing class SobjectTableCtrl {
	public static Map<String, Type> sobjectTableServiceImpl = new Map<String, Type>{
		'default' => SobjectTableServiceDefault.class
	};

	@AuraEnabled
	public static Map<String, Object> init(String controllerName, String inputDataJSON){
		SobjectTableServiceAbstract sobjectTableService =(SobjectTableServiceAbstract)JSON.deserialize(
			inputDataJSON,
			sobjectTableServiceImpl.get(controllerName)
		);

		return new Map<String, Object>{
			'records'             => sobjectTableService.sobjectRecords(),
			'recordsCount'        => sobjectTableService.recordsCount(),
			'referenceFieldPaths' => sobjectTableService.referenceFieldPaths(),
			'addressFieldPaths'   => sobjectTableService.addressFieldPaths(),
			'dataTableColumns'    => sobjectTableService.dataTableColumns()
		};
	}

	public class SobjectTableException extends Exception {}
}
