/**
 * @author Andrei Kakhanouski <akohan91@gmail.com>
 */
public with sharing class SobjectTableCtrl {

	/* FACTORY METHOD */

	private static SobjectTableServiceAbstract controllerInstance(String controllerName, String inputDataJSON) {
		controllerName = controllerName == null ? SobjectTableServiceDefault.class.getName() : controllerName;
		String constructorName = controllerName + '.Constructor';
		Type constructorType = Type.forName(constructorName);

		if (constructorType == null) {
			throw new SobjectTableException('Constructor ' + constructorName + ' not found.');
		}
		return ((SobjectTableServiceAbstract.IConstructable)constructorType.newInstance()).construct(inputDataJSON);
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
