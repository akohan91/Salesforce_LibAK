/**
 * @author Andrei Kakhanouski <akohan91@gmail.com>
 */
@IsTest
public with sharing class TestDynamicSOQLCondition {
	@IsTest
	static void testConstructorValueAsObject(){
		DynamicSOQLCondition condition = new DynamicSOQLCondition('IsDeleted', '=', false);

		Test.startTest();

		String result = condition.stringify('Account');

		Test.stopTest();

		System.assertEquals('IsDeleted = false', result, 'The "stringify" method returns wrong value.');
	}

	@IsTest
	static void testConstructorWithFunction(){
		DynamicSOQLCondition condition = new DynamicSOQLCondition(new DynamicSOQLFunction('COUNT', 'Id'), '>', 10);

		Test.startTest();

		String result = condition.stringify('Account');

		Test.stopTest();

		System.assertEquals('COUNT(Id) > 10', result, 'The "stringify" method returns wrong value.');
	}

	@IsTest
	static void testConstructorValueAsDateTime(){
		Datetime value = Datetime.newInstance(2022, 01, 01, 01, 01, 01);
		DynamicSOQLCondition condition = new DynamicSOQLCondition('CreatedDate', '=', value);

		Test.startTest();

		String result = condition.stringify('Account');

		Test.stopTest();

		System.assertEquals(
			'CreatedDate = ' + value.formatGmt(DynamicSOQLConstants.FORMAT_DATE_TIME),
			result,
			'The "stringify" method returns wrong value.'
		);
	}

	@IsTest
	static void testConstructorValueAsDate(){
		Date value = Date.newInstance(2022, 01, 01);
		DynamicSOQLCondition condition = new DynamicSOQLCondition('Birthdate', '=', value);

		Test.startTest();

		String result = condition.stringify('Contact');

		Test.stopTest();

		System.assertEquals(
			'Birthdate = ' + ((Datetime)value).formatGmt(DynamicSOQLConstants.FORMAT_DATE),
			result,
			'The "stringify" method returns wrong value.'
		);
	}

	@IsTest
	static void testConstructorValueAsString(){
		DynamicSOQLCondition condition = new DynamicSOQLCondition('Name', '=', 'It\'s a string');

		Test.startTest();

		String result = condition.stringify('Account');

		Test.stopTest();

		System.assertEquals('Name = \'It\\\'s a string\'', result, 'The "stringify" method returns wrong value.');
	}

	@IsTest
	static void testConstructorValuesList(){
		DynamicSOQLCondition condition = new DynamicSOQLCondition('Name', 'IN', new List<String>{'It\'s a string', 'It\'s another string'});

		Test.startTest();

		String result = condition.stringify('Account');

		Test.stopTest();

		System.assertEquals(
			'Name IN (\'It\\\'s a string\',\'It\\\'s another string\')',
			result,
			'The "stringify" method returns wrong value.'
		);
	}

	@IsTest
	static void testConstructorValuesListINCLUDES(){
		DynamicSOQLCondition condition = new DynamicSOQLCondition('Name', 'INCLUDES', new List<String>{'value1', 'value2', 'value3'});

		Test.startTest();

		String result = condition.stringify('Account');

		Test.stopTest();

		System.assertEquals(
			'Name INCLUDES (value1;value2;value3)',
			result,
			'The "stringify" method returns wrong value.'
		);
	}

	@IsTest
	static void testConstructorValuesListEXCLUDES(){
		DynamicSOQLCondition condition = new DynamicSOQLCondition('Name', 'EXCLUDES', new List<String>{'value1', 'value2', 'value3'});

		Test.startTest();

		String result = condition.stringify('Account');

		Test.stopTest();

		System.assertEquals(
			'Name EXCLUDES (value1;value2;value3)',
			result,
			'The "stringify" method returns wrong value.'
		);
	}

	@IsTest
	static void testConstructorDynamicSOQLAsCondition(){
		DynamicSOQLCondition condition = new DynamicSOQLCondition('AccountId', 'IN',
			new DynamicSOQL('Account')
			.withField('Id')
			.withConditions(
				new DynamicSOQLConditionBlock('AND')
				.addCondition(new DynamicSOQLCondition('Industry', '=', 'Government'))
			)
		);

		Test.startTest();

		String result = condition.stringify('Contact');

		Test.stopTest();

		System.assertEquals(
			'AccountId IN (SELECT Id FROM Account WHERE (Industry = \'Government\'))',
			result,
			'The "stringify" method returns wrong value.'
		);
	}

	@IsTest
	static void testConstructorValueAsStringVariable(){
		DynamicSOQLCondition condition = new DynamicSOQLCondition('Name', '=:', 'variableName');

		Test.startTest();

		String result = condition.stringify('Account');

		Test.stopTest();

		System.assertEquals('Name =: variableName', result, 'The "stringify" method returns wrong value.');
	}

	@IsTest
	static void testConstructorValueAsNull(){
		DynamicSOQLCondition condition = new DynamicSOQLCondition('Name', '=', (String)null);

		Test.startTest();

		String result = condition.stringify('Account');

		Test.stopTest();

		System.assertEquals(
			'Name = null', result,
			'The "stringify" method returns wrong value.'
		);
	}

	@IsTest
	static void testfieldApiName(){
		DynamicSOQLCondition condition = new DynamicSOQLCondition('Name', '=', 'Test');

		Test.startTest();

		String result = condition.fieldApiname();

		Test.stopTest();

		System.assertEquals('Name', condition.fieldApiname(), 'The "fieldApiname()" method returns wrong value.');
	}

	@IsTest
	static void testfieldApiNameWithFunction(){
		DynamicSOQLCondition condition = new DynamicSOQLCondition(new DynamicSOQLFunction('COUNT', 'Id'), '>', 10);

		Test.startTest();

		String result = condition.fieldApiname();

		Test.stopTest();

		System.assertEquals('Id', result, 'The "fieldApiname()" method returns wrong value.');
	}

	@IsTest
	static void testNoFieldApiNameInSOQLConditionError(){
		DynamicSOQLCondition condition = (DynamicSOQLCondition)JSON.deserialize('{"function": null, "fieldName": null, "operator": "=", "value": "test" }', DynamicSOQLCondition.class);
		Integer errorCount = 0;

		Test.startTest();

		try {
			condition.fieldApiname();
		} catch (Exception exc) {
			errorCount++;
		}

		Test.stopTest();

		System.assertEquals(1, errorCount, 'The error was not occurred.');
	}

	@IsTest
	static void testToStringWrongOperator(){
		DynamicSOQLCondition condition = new DynamicSOQLCondition('Name', 'wrongOperator', 'It\'s a string');
		Integer errorCount = 0;

		Test.startTest();

		try {
			condition.stringify('Account');
		} catch (Exception exc) {
			errorCount++;
		}

		Test.stopTest();

		System.assertEquals(1, errorCount, 'The error was not occurred.');
	}
}
