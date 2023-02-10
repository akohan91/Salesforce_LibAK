/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
@IsTest
public with sharing class TestDynamicSOQLConditionBlock {
	@IsTest
	static void testConditionBlockSingleCondition(){
		DynamicSOQLConditionBlock conditionBlock = new DynamicSOQLConditionBlock('AND')
			.addCondition(new DynamicSOQLCondition('Name', '=', 'Test Name'));

		Test.startTest();

		String result = conditionBlock.stringify('Account');

		Test.stopTest();

		System.assertEquals('(Name = \'Test Name\')', result, 'The stringify() method returns wrong value');
	}

	@IsTest
	static void testConditionBlockSeveralContitions(){
		DynamicSOQLConditionBlock conditionBlock = new DynamicSOQLConditionBlock('AND')
			.addCondition(new DynamicSOQLCondition('FirstName', '=', 'Test Name'))
			.addCondition(new DynamicSOQLCondition('LastName', '=', 'Test Name'))
			.addCondition(new DynamicSOQLCondition('Birthdate', '<', Date.newInstance(2022,01,01)));

		Test.startTest();

		String result = conditionBlock.stringify('Contact');

		Test.stopTest();

		System.assertEquals(
			'(FirstName = \'Test Name\' AND LastName = \'Test Name\' AND Birthdate < 2022-01-01)',
			result,
			'The stringify() method returns wrong value'
		);
	}

	@IsTest
	static void testConditionBlockSeveralContitionBlocks(){
		DynamicSOQLConditionBlock conditionBlock = new DynamicSOQLConditionBlock('AND')
			.addConditionBlock(
				new DynamicSOQLConditionBlock('OR')
				.addCondition(new DynamicSOQLCondition('FirstName', '=', 'Test Name 1'))
				.addCondition(new DynamicSOQLCondition('FirstName', '=', 'Test Name 2'))
			).addConditionBlock(
				new DynamicSOQLConditionBlock('OR')
				.addCondition(new DynamicSOQLCondition('LastName', '=', 'Test Name 1'))
				.addCondition(new DynamicSOQLCondition('LastName', '=', 'Test Name 2'))
			).addCondition(new DynamicSOQLCondition('Birthdate', '<', Date.newInstance(2022,01,01)));

		Test.startTest();

		String result = conditionBlock.stringify('Contact');

		Test.stopTest();

		System.assertEquals(
			'((FirstName = \'Test Name 1\' OR FirstName = \'Test Name 2\') AND (LastName = \'Test Name 1\' OR LastName = \'Test Name 2\') AND Birthdate < 2022-01-01)',
			result,
			'The stringify() method returns wrong value'
		);
	}

	@IsTest
	static void testSwitchOperator(){
		DynamicSOQLConditionBlock conditionBlock = new DynamicSOQLConditionBlock('AND')
			.addCondition(new DynamicSOQLCondition('FirstName', '=', 'Test Name'))
			.addCondition(new DynamicSOQLCondition('LastName', '=', 'Test Name'))
			.addCondition(new DynamicSOQLCondition('Birthdate', '<', Date.newInstance(2022,01,01)));

		System.assertEquals(
			'(FirstName = \'Test Name\' AND LastName = \'Test Name\' AND Birthdate < 2022-01-01)',
			conditionBlock.stringify('Contact'),
			'The stringify() method returns wrong value'
		);

		Test.startTest();

		conditionBlock.switchOperator('OR');

		Test.stopTest();

		System.assertEquals(
			'(FirstName = \'Test Name\' OR LastName = \'Test Name\' OR Birthdate < 2022-01-01)',
			conditionBlock.stringify('Contact'),
			'The stringify() method returns wrong value'
		);
	}

	@IsTest
	static void testFieldsApiNames(){
		Test.startTest();
		DynamicSOQLConditionBlock conditionBlock = new DynamicSOQLConditionBlock('AND')
		.addConditionBlock(
			new DynamicSOQLConditionBlock('OR')
			.addCondition(new DynamicSOQLCondition('Phone', '=', '121345'))
		)
		.addCondition(new DynamicSOQLCondition('FirstName', '=', 'Test'))
		.addCondition(new DynamicSOQLCondition('LastName', '=', 'Test'));

		System.assertEquals(
			3, conditionBlock.fieldsApiNames().size(),
			'The number of fields thet the "fieldsApiNames()" method returns is wrong.'
		);
		System.assert(
			conditionBlock.fieldsApiNames().containsAll(new Set<String>{'Phone', 'FirstName', 'LastName'}),
			'The "fieldsApiNames()" method returns wrong value.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testToStringWrongOperator(){
		Test.startTest();
		Integer errorCount = 0;
		try {
			new DynamicSOQLConditionBlock('AND')
			.addCondition(new DynamicSOQLCondition('Name', '=', 'Test'))
			.switchOperator('wrong')
			.stringify('Account');
		} catch (Exception exc) {
			errorCount++;
		}

		System.assertEquals(
			1, errorCount,
			'The WrongComparisonOperator error was not occured.'
		);
		Test.stopTest();
	}
}
