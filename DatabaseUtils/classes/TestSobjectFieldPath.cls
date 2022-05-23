@IsTest
public with sharing class TestSobjectFieldPath {
	@IsTest
	static void testConstructor(){
		Test.startTest();
		SobjectFieldPath instance = new SobjectFieldPath('Contact', 'Account.Name');
		System.assertEquals(
			Contact.getSObjectType(), instance.sObjectType,
			'The "sObjectType" property of SobjectFieldPath instance is wrong.'
		);
		System.assertEquals(
			'account.name', instance.path(),
			'The "path" property of SobjectFieldPath instance is wrong.'
		);
		System.assertEquals(
			'Contact', instance.targetSobjectDescribe.getName(),
			'The "targetFieldDescribe" property of SobjectFieldPath instance is wrong.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testConstructorWrongSobjectAPI(){
		Test.startTest();
		Integer errorCount = 0;
		try {
			SobjectFieldPath instance = new SobjectFieldPath('WrongSobject', 'Account.Name');
		} catch (Exception exc) {
			errorCount++;
			System.assertEquals(
				Label.NoSobjectTemplate.replace('{sobject}', 'WrongSobject'), exc.getMessage(),
				'The error message is wrong.'
			);
		}
		System.assertEquals(
			1, errorCount,
			'The "NoSobject" error was not occurred.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testTargetReferencePath(){
		Test.startTest();
		SobjectFieldPathInterface noReferenceInstance = new SobjectFieldPath('Contact', 'Account.Name');
		System.assertEquals(
			'account.id', noReferenceInstance.targetReferencePath(),
			'The targetReferencePath() method return wrong value.'
		);
		SobjectFieldPathInterface referenceInstance = new SobjectFieldPath('Contact', 'AccountId');
		System.assertEquals(
			'account.id', referenceInstance.targetReferencePath(),
			'The targetReferencePath() method return wrong value.'
		);
		SobjectFieldPathInterface idInstance = new SobjectFieldPath('Contact', 'Account.Id');
		System.assertEquals(
			'account.id', idInstance.targetReferencePath(),
			'The targetReferencePath() method return wrong value.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testTargetFieldDescribe(){
		Test.startTest();
		SobjectFieldPathInterface instance = new SobjectFieldPath('Contact', 'Account.Name');
		System.assertEquals(
			'Name', instance.targetFieldDescribe().getName(),
			'The targetFieldDescribe() method return wrong value.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testWrongFieldPath(){
		Test.startTest();
		Integer errorCount = 0;
		try {
			SobjectFieldPathInterface instance = new SobjectFieldPath('Contact', 'WrongField');
			instance.targetFieldDescribe();
		} catch (Exception exc) {
			errorCount++;
			System.assertEquals(
				Label.NoSobjectFieldTemplate
					.replace('{pathItem}', 'wrongfield')
					.replace('{sobject}', 'Contact'),
				exc.getMessage(),
				'The error message is wrong.'
			);
		}
		System.assertEquals(
			1, errorCount,
			'The "NoSobjectField" error was not occurred.'
		);

		errorCount = 0;

		try {
			SobjectFieldPathInterface instance = new SobjectFieldPath('Contact', 'WrongField.Name');
			instance.targetFieldDescribe();
		} catch (Exception exc) {
			errorCount++;
			System.assertEquals(
				Label.NoSobjectFieldTemplate
					.replace('{pathItem}', 'wrongfieldid')
					.replace('{sobject}', 'Contact'),
				exc.getMessage(),
				'The error message is wrong.'
			);
		}
		System.assertEquals(
			1, errorCount,
			'The "NoSobjectField" error was not occurred.'
		);
		Test.stopTest();
	}
}
