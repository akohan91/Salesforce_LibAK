/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
public with sharing class SobjectTableCtrl {

	/* FACTORY METHOD */

	private static SobjectTableServiceAbstract controllerInstance(String controllerName, String inputDataJSON) {
		if (controllerName == null) {
			return (SobjectTableServiceAbstract)JSON.deserialize(inputDataJSON, SobjectTableServiceDefault.class);
		} else {
			Type serviceType = Type.forName(controllerName);

			if (serviceType == null) {
				throw new SobjectTableException('Service ' + controllerName + ' not found.');
			}
			return ((SobjectTableServiceAbstract)serviceType.newInstance()).createService(inputDataJSON);
		}
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
