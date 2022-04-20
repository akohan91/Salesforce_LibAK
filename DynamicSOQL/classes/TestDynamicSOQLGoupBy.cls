@IsTest
public with sharing class TestDynamicSOQLGoupBy {
	@IsTest
	static void testConstructor(){
		Test.startTest();
		List<String> fieldGroupByList = new List<String>{'Name'};
		DynamicSOQLGoupBy groupBy = new DynamicSOQLGoupBy(fieldGroupByList);
		System.assertEquals(
			fieldGroupByList, groupBy.fieldGroupByList,
			'The fieldGroupByList property of DynamicSOQLGoupBy instance is wrong.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testFieldsList(){
		Test.startTest();
		List<String> fieldGroupByList = new List<String>{'Name'};
		DynamicSOQLGoupBy groupBy = new DynamicSOQLGoupBy(fieldGroupByList);
		System.assertEquals(
			fieldGroupByList, groupBy.fieldsList(),
			'The "fieldsList()" method returns wrong list of fields.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testToStringWithHaving(){
		Test.startTest();
		DynamicSOQLGoupBy groupBy = new DynamicSOQLGoupBy(new List<String>{'Name'})
		.withHaving(
			new DynamicSOQLConditionBlock('AND')
			.addCondition(new DynamicSOQLCondition('COUNT(Name)', '>', 10))
		);
		System.assertEquals(
			'GROUP BY Name HAVING (COUNT(Name) > 10)', groupBy.toString(),
			'The "toString()" method returns wrong GROUP BY statement.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testToString(){
		Test.startTest();
		DynamicSOQLGoupBy groupBy = new DynamicSOQLGoupBy(new List<String>{'Name'});
		System.assertEquals(
			'GROUP BY Name', groupBy.toString(),
			'The "toString()" method returns wrong GROUP BY statement.'
		);
		Test.stopTest();
	}
}
