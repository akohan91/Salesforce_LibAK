@IsTest
public with sharing class TestDynamicSOQLOrderBy {
	@IsTest
	static void testOrderBy(){
		Test.startTest();
		DynamicSOQLOrderBy orderBy = new DynamicSOQLOrderBy(new List<String>{'Name', 'Id'});
		System.assertEquals(
			'ORDER BY Name,Id ASC NULLS LAST', orderBy.toString(),
			'The toString() method returns wrong value,'
		);
		orderBy = new DynamicSOQLOrderBy(new List<String>{'Name', 'Id'}, true);
		System.assertEquals(
			'ORDER BY Name,Id DESC NULLS LAST', orderBy.toString(),
			'The toString() method returns wrong value,'
		);
		Test.stopTest();
	}
}
