@IsTest
public with sharing class TestDynamicSOQLOrderBy {
	@IsTest
	static void testOrderBy(){
		Test.startTest();
		DynamicSOQLOrderBy orderBy = new DynamicSOQLOrderBy(new List<String>{'Name', 'Id'});
		System.assertEquals(
			'ORDER BY Name,Id ASC NULLS LAST', orderBy.stringify(),
			'The toString() method returns wrong value,'
		);
		orderBy = new DynamicSOQLOrderBy(new List<String>{'Name', 'Id'}, true);
		System.assertEquals(
			'ORDER BY Name,Id DESC NULLS LAST', orderBy.stringify(),
			'The toString() method returns wrong value,'
		);
		Test.stopTest();
	}

	@IsTest
	static void testFieldsApiNames(){
		Test.startTest();
		List<String> fields = new List<String>{'Name', 'Id'};
		DynamicSOQLOrderBy orderBy = new DynamicSOQLOrderBy(fields);
		System.assertEquals(
			fields, orderBy.fieldsApiNames(),
			'The "fieldsApiNames()" method returns wrong list of fields.'
		);
		Test.stopTest();
	}
}
