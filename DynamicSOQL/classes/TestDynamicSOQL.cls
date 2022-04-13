/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
@IsTest
private class TestDynamicSOQL {

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
			'Contacts',
			new DynamicSOQL('Contact')
			.withField('Id')
		);
		System.assertEquals(
			1, soql.subQueries.size(),
			'The number of added subqueries is wrong.'
		);
		System.assertEquals(
			'SELECT Name,(SELECT Id FROM Contacts) FROM Account', soql.toString(),
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
			new DynamicSOQL('Account')
			.withField('Name')
			.withSubQuery(
				'Products',
				new DynamicSOQL('Product2')
				.withField('Id')
			).toString();
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
	static void testWithConditions(){
		Test.startTest();
		DynamicSOQL soql = new DynamicSOQL('Account')
		.withField('Id')
		.withConditions(
			new DynamicSOQLConditionBlock('AND')
			.addCondition( new DynamicSOQLCondition('Name', '=', 'Test'))
		);
		System.assertEquals(
			'SELECT Id FROM Account WHERE (Name = \'Test\')', soql.toString(),
			'The toString() method returns wrong value.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testInfoToFLSCheck(){
		Test.startTest();
		Map<String,Set<String>> infoToFLSCheck = new DynamicSOQL('Account')
		.withField('Id')
		.withField('Name')
		.withSubQuery(
			'Contact',
			new DynamicSOQL('Contact')
			.withField('Id')
			.withField('FirstName')
		)
		.withConditions(
			new DynamicSOQLConditionBlock('AND')
			.addCondition(new DynamicSOQLCondition('Phone', '=', '12345'))
		).infoToFLSCheck();

		System.assert(
			infoToFLSCheck.containsKey('Account'),
			'The infoToFLSCheck should contain the "Account" key.'
		);
		System.assert(
			infoToFLSCheck.containsKey('Contact'),
			'The infoToFLSCheck should contain the "Contact" key.'
		);
		System.assert(
			infoToFLSCheck.get('Account').containsAll(new Set<String>{'Id','Name','Phone'}),
			'The infoToFLSCheck.Account containa wrong set of fields. Actual: ' +
				infoToFLSCheck.get('Account') + ' Expected: ' + new Set<String>{'Id','Name','Phone'}
		);
		System.assert(
			infoToFLSCheck.get('Contact').containsAll(new Set<String>{'Id','FirstName'}),
			'The infoToFLSCheck.Contact containa wrong set of fields. Actual: ' +
				infoToFLSCheck.get('Contact') + ' Expected: ' + new Set<String>{'Id','FirstName'}
		);
		Test.stopTest();
	}

	@IsTest
	static void testToString(){
		Test.startTest();
		String soql = new DynamicSOQL('Account')
		.withField('Id')
		.withSubQuery('Contacts', new DynamicSOQL('Contact').withField('Id'))
		.toString();
		System.assertEquals(
			'SELECT Id,(SELECT Id FROM Contacts) FROM Account', soql,
			'The SOQL String is wrong.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testToStringNoSObject(){
		Test.startTest();
		Integer excCount = 0;
		try {
			new DynamicSOQL('FakeSobject').toString();
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
}
