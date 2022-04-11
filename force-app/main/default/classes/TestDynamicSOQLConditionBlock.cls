/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
@IsTest
public with sharing class TestDynamicSOQLConditionBlock {
	@IsTest
	static void testConstructor(){
		Test.startTest();
		DynamicSOQLConditionBlock conditionBlock = new DynamicSOQLConditionBlock('AND');
		System.assertEquals(
			'AND', conditionBlock.operator,
			'The operator property is wrong.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testAddConditionBlock(){
		Test.startTest();
		DynamicSOQLConditionBlock conditionBlock = new DynamicSOQLConditionBlock('AND')
		.addConditionBlock(new DynamicSOQLConditionBlock('OR'))
		.addConditionBlock(new DynamicSOQLConditionBlock('OR'));
		System.assertEquals(
			2, conditionBlock.blocks.size(),
			'The number of DynamicSOQLConditionBlock instances of "blocks" property is wrong.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testAddCondition(){
		Test.startTest();
		DynamicSOQLConditionBlock conditionBlock = new DynamicSOQLConditionBlock('AND')
		.addCondition(new DynamicSOQLCondition('Name', '=', 'Test'))
		.addCondition(new DynamicSOQLCondition('Name', '=', 'Test'));
		System.assertEquals(
			2, conditionBlock.conditions.size(),
			'The number of DynamicSOQLCondition instances of "conditions" property is wrong.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testSwitchOperator(){
		Test.startTest();
		DynamicSOQLConditionBlock conditionBlock = new DynamicSOQLConditionBlock('AND')
		.addCondition(new DynamicSOQLCondition('Name', '=', 'Test'))
		.switchOperator('OR');
		System.assertEquals(
			'OR', conditionBlock.operator,
			'The operator property is wrong.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testSwitchOperatorWrongOperator(){
		Test.startTest();
		Integer errorCount = 0;
		try {
			DynamicSOQLConditionBlock conditionBlock = new DynamicSOQLConditionBlock('AND')
			.addCondition(new DynamicSOQLCondition('Name', '=', 'Test'))
			.switchOperator('wrong');
		} catch (Exception exc) {
			errorCount++;
		}

		System.assertEquals(
			1, errorCount,
			'The WrongComparisonOperator error was not occured.'
		);
		Test.stopTest();
	}


	@IsTest
	static void testToString(){
		Test.startTest();
		String conditionString = new DynamicSOQLConditionBlock('OR')
		.addConditionBlock(
			new DynamicSOQLConditionBlock('OR')
			.addCondition(new DynamicSOQLCondition('Name', '=', 'Test1'))
			.addCondition(new DynamicSOQLCondition('Name', '=', 'Test2'))
		).toString();
		System.assertEquals(
			'((Name = \'Test1\' OR Name = \'Test2\'))', conditionString,
			'The operator property is wrong.'
		);
		Test.stopTest();
	}
}
