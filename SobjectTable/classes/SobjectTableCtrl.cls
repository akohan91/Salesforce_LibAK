/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
public with sharing class SobjectTableCtrl {
	private static Map<String, Type> sobjectTableServiceImpl = new Map<String, Type>{
		'default' => SobjectTableServiceDefault.class
	};

	/* FACTORY METHOD */

	private static SobjectTableServiceAbstract controllerInstance(String controllerName, String inputDataJSON) {
		Type serviceType = sobjectTableServiceImpl.get(controllerName);
		return ((SobjectTableServiceAbstract)serviceType.newInstance())
			.createService(inputDataJSON);
	}

	/* PUBLIC METHODS */

	@AuraEnabled
	public static Map<String, Object> init(String controllerName, String inputDataJSON){
		try {
			SobjectTableServiceAbstract sobjectTableService = controllerInstance(controllerName, inputDataJSON);
			return new Map<String, Object>{
				'records'             => sobjectTableService.tableRows(),
				'recordsCount'        => sobjectTableService.recordsCount(),
				'referenceFieldPaths' => sobjectTableService.referenceFieldPaths(),
				'addressFieldPaths'   => sobjectTableService.addressFieldPaths(),
				'dataTableColumns'    => sobjectTableService.dataTableColumns()
			};
		} catch (Exception exc) {
			throw new SobjectTableException(exc.getMessage());
		}
	}

	public class SobjectTableException extends Exception {}
}
