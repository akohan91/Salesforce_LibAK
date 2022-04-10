@IsTest
private class DynamicSOQLTest {

	@IsTest
	static void testConstructor(){
		Test.startTest();
		DynamicSOQL soql = new DynamicSOQL('Account');
		System.assertEquals(
			'Account', soql.sObjectName,
			'The sObjectName property of DynamicSOQL instance is wrong.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testConstructorNoSObject(){
		Test.startTest();
		Integer excCount = 0;
		try {
			DynamicSOQL soql = new DynamicSOQL('FakeSobject');
		} catch (Exception exc) {
			excCount++;
			System.assertEquals(
				Label.NoSObject.replace('{sObjectName}', 'FakeSobject'), exc.getMessage(),
				'The NoSObject error message is wrong.'
			);
		}
		System.assertEquals(
			1, excCount,
			'The NoSObject exception was not occurred.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testConstructorSObjectAccessError(){
		Test.startTest();
		/**
			TODO:
			Implement test method for some Profile
			Could be implemented after creating TestFactory class
		 */
		Test.stopTest();
	}

	@IsTest
	static void testWithField(){
		Test.startTest();
		DynamicSOQL soql = new DynamicSOQL('Account')
		.withField('Id')
		.withField('Name')
		.withField('OwnerId');
		System.assertEquals(
			3, soql.fields.size(),
			'The number of fields is wrong.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testWithSubQuery(){
		Test.startTest();
		DynamicSOQL soql = new DynamicSOQL('Account')
		.withField('Name')
		.withSubQuery(
			new DynamicSOQL('Contact')
			.withField('Id')
		);
		System.assertEquals(
			1, soql.subQueries.size(),
			'The number of added subqueries is wrong.'
		);
		System.assertEquals(
			'(SELECT Id FROM Contacts)', soql.subQueries[0],
			'The value of added subquery is wrong.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testWithSubQueryNoChildSObject(){
		/**
			TODO:
			Potentially should be rewrited with more flexible way
			to prevent hardcoded child sObject api name
		 */
		Test.startTest();
		Integer excCount = 0;
		try {
			DynamicSOQL soql = new DynamicSOQL('Account')
			.withField('Name')
			.withSubQuery(
				new DynamicSOQL('Product2')
				.withField('Id')
			);
		} catch (Exception exc) {
			excCount++;
			System.assertEquals(
				Label.NoChildSObject
					.replace('{childSObjectName}', 'Product2')
					.replace('{sObjectName}', 'Account'),
				exc.getMessage(),
				'The NoChildSObject error message is wrong.'
			);
		}
		System.assertEquals(
			1, excCount,
			'The NoChildSObject exception was not occurred.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testSoqlString(){
		Test.startTest();
		String soql = new DynamicSOQL('Account')
		.withField('Id')
		.withSubQuery(new DynamicSOQL('Contact').withField('Id'))
		.soqlString();
		System.assertEquals(
			'SELECT Id,(SELECT Id FROM Contacts) FROM Account', soql,
			'The SOQL String is wrong.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testConstructorFLSError(){
		Test.startTest();
		/**
			TODO:
			Implement test method for some Profile
			Could be implemented after creating TestFactory class
		 */
		Test.stopTest();
	}
}
