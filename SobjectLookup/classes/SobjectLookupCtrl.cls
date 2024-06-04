/**
 * @author Andrei Kakhanouski <akohan91@gmail.com>
 */
public with sharing class SobjectLookupCtrl {
	private static Map<String, Type> sobjectLookupServiceImpl = new Map<String, Type>{
		'default' => SobjectLookupServiceDefault.class
	};

	/* FACTORY METHOD */

	private static SobjectLookupServiceAbstract serviceInstance(String controllerName, String inputJSON) {
		controllerName = controllerName == null ? SobjectLookupServiceDefault.class.getName() : controllerName;
		String constructorName = controllerName + '.Constructor';
		Type constructorType = Type.forName(constructorName);

		if (constructorType == null) {
			throw new SobjectLookupException('Constructor ' + constructorName + ' not found.');
		}
		return ((SobjectLookupServiceAbstract.IConstructable)constructorType.newInstance()).construct(inputJSON);
	}

	@AuraEnabled
	public static Map<String,Object> search(String controllerName, String inputJSON){
		try {
			SobjectLookupServiceAbstract sobjectLookupService = serviceInstance(controllerName, inputJSON);
			return new Map<String, Object>{
				'records'      => sobjectLookupService.sobjectRecords(),
				'recordsCount' => sobjectLookupService.recordsCount()
			};
		} catch (Exception exc) {
			throw new SobjectLookupException(exc.getMessage());
		}
	}

	public class SobjectLookupException extends Exception {}
}
