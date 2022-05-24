@IsTest
public with sharing class TestSobjectTableServiceDefault {
	@TestSetup
	static void makeData(){
		Account acc = new Account(
			Name = 'Test Account Name',
			BillingCountry = 'Greece',
			BillingState = 'Montana',
			BillingPostalCode = '23356',
			BillingCity = 'South Alvinside',
			BillingStreet = '56 Arely Street Apt. 535'
		);
		Database.insert(acc);
		List<Contact> cons = new List<Contact>();
		for (Integer i = 0; i < 15; i++) {
			cons.add(new Contact(
				FirstName = 'FirstName',
				LastName = 'LastName ' + i,
				AccountId = acc.Id
			));
		}
		Database.insert(cons);
	}

	@IsTest
	static void testSobjectRecords(){
		Test.startTest();
		SobjectTableServiceAbstract instance = getInstance();
		List<Contact> result = (List<Contact>)instance.sobjectRecords();
		System.assertEquals(
			10, result.size(),
			'The number of selected records is wrong.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testRecordsCount(){
		Test.startTest();
		SobjectTableServiceAbstract instance = getInstance();
		Integer result = instance.recordsCount();
		System.assertEquals(
			15, result,
			'The number of all records is wrong.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testAddressFieldPaths(){
		Test.startTest();
		SobjectTableServiceAbstract instance = getInstance();
		List<String> result = instance.addressFieldPaths();
		System.assertEquals(
			1, result.size(),
			'The number of address fields is wrong.'
		);
		System.assertEquals(
			'account.billingaddress', result[0],
			'The address field is wrong.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testReferenceFieldPaths(){
		Test.startTest();
		SobjectTableServiceAbstract instance = getInstance();
		List<String> result = instance.referenceFieldPaths();
		System.assertEquals(
			1, result.size(),
			'The number of reference fields is wrong.'
		);
		System.assertEquals(
			'id', result[0],
			'The reference field is wrong.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testDataTableColumns(){
		Test.startTest();
		SobjectTableServiceAbstract instance = getInstance();
		List<Object> result = instance.dataTableColumns();
		System.assertEquals(
			3, result.size(),
			'The number of DataTableColumns is wrong.'
		);
		Test.stopTest();
	}

	private static SobjectTableServiceAbstract getInstance() {
		SobjectTableServiceAbstract instance = new SobjectTableServiceDefault();
		instance.sobjectName = 'Contact';
		instance.selectFields = new List<String>{'Name', 'Account.BillingAddress', 'Account.Type'};
		instance.conditionBlock = new DynamicSOQLConditionBlock('AND')
			.addCondition(new DynamicSOQLCondition('Account.Name', '=', 'Test Account Name'));
		instance.orderBy = new DynamicSOQLOrderBy(new List<String>{'Name'});
		instance.limitRecords = 10;
		instance.offsetRecords = 0;
		return instance;
	}
}
