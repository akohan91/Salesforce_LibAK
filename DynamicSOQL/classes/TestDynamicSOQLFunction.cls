@IsTest
public with sharing class TestDynamicSOQLFunction {

	@IsTest
	static void testToStringWithAlias(){
		Test.startTest();
		System.assertEquals(
			'COUNT(Id) alias', new DynamicSOQLFunction('COUNT', 'Id', 'alias').toString(),
			'The "toString()" method returns wrong value.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testToStringWithoutAlias(){
		Test.startTest();
		System.assertEquals(
			'COUNT(Id)', new DynamicSOQLFunction('COUNT', 'Id').toString(),
			'The "toString()" method returns wrong value.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testToStringWithoutFieldName(){
		Test.startTest();
		System.assertEquals(
			'COUNT()', new DynamicSOQLFunction('COUNT').toString(),
			'The "toString()" method returns wrong value.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testfieldApiName(){
		Test.startTest();
		System.assertEquals(
			'Id', new DynamicSOQLFunction('COUNT', 'Id', 'alias').fieldApiname(),
			'The "fieldApiname()" method returns wrong value.'
		);
		Test.stopTest();
	}
}
