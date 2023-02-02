@IsTest
public with sharing class TestDynamicSOQLGroupBy {
	@IsTest
	static void testConstructor(){
		Test.startTest();
		List<String> fieldGroupByList = new List<String>{'Name'};
		DynamicSOQLGroupBy groupBy = new DynamicSOQLGroupBy(fieldGroupByList);
		System.assertEquals(
			fieldGroupByList, groupBy.fieldGroupByList,
			'The fieldGroupByList property of DynamicSOQLGoupBy instance is wrong.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testFieldsApiNames(){
		Test.startTest();
		List<String> fieldGroupByList = new List<String>{'Name'};
		DynamicSOQLGroupBy groupBy = new DynamicSOQLGroupBy(fieldGroupByList);
		System.assertEquals(
			fieldGroupByList, groupBy.fieldsApiNames(),
			'The "fieldsApiNames()" method returns wrong list of fields.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testToStringWithHaving(){
		Test.startTest();
		DynamicSOQLGroupBy groupBy = new DynamicSOQLGroupBy(new List<String>{'Name'})
		.withHaving(
			new DynamicSOQLConditionBlock('AND')
			.addCondition(new DynamicSOQLCondition(new DynamicSOQLFunction('COUNT', 'Name'), '>', 10))
		);
		System.assertEquals(
			'GROUP BY Name HAVING (COUNT(Name) > 10)', groupBy.stringify('Account'),
			'The "stringify" method returns wrong GROUP BY statement.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testToString(){
		Test.startTest();
		DynamicSOQLGroupBy groupBy = new DynamicSOQLGroupBy(new List<String>{'Name'});
		System.assertEquals(
			'GROUP BY Name', groupBy.stringify('Account'),
			'The "stringify()" method returns wrong GROUP BY statement.'
		);
		Test.stopTest();
	}
}
