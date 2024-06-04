@IsTest
public with sharing class TestSobjectTableCtrl {
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
	static void testInit(){
		Test.startTest();
		Map<String, Object> result = SobjectTableCtrl.init(
			null,
			JSON.serialize(getSobjectTableServiceInstance())
		);
		List<Contact> records            = (List<Contact>)result.get('records');
		Integer recordsCount             = (Integer)result.get('recordsCount');
		List<Object> addressFieldPaths   = (List<Object>)result.get('addressFieldPaths');
		List<Object> referenceFieldPaths = (List<Object>)result.get('referenceFieldPaths');
		List<Object> dataTableColumns    = (List<Object>)result.get('dataTableColumns');

		System.assertEquals(
			10, records.size(),
			'The number of selected records is wrong.'
		);
		System.assertEquals(
			15, recordsCount,
			'The number of all records is wrong.'
		);
		System.assertEquals(
			1, addressFieldPaths.size(),
			'The number of address fields is wrong.'
		);
		System.assertEquals(
			'account.billingaddress', (String)addressFieldPaths[0],
			'The address field is wrong.'
		);
		System.assertEquals(
			1, referenceFieldPaths.size(),
			'The number of reference fields is wrong.'
		);
		System.assertEquals(
			'id', (String)referenceFieldPaths[0],
			'The reference field is wrong.'
		);
		System.assertEquals(
			3, dataTableColumns.size(),
			'The number of DataTableColumns is wrong.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testInitError(){
		Test.startTest();
		Integer errorCount = 0;
		try {
			SobjectTableServiceAbstract sobjectTableServiceInstance = getSobjectTableServiceInstance();
			sobjectTableServiceInstance.selectFields.add('WrongField');
			Map<String, Object> result = SobjectTableCtrl.init(
				'default',
				JSON.serialize(sobjectTableServiceInstance)
			);
		} catch (Exception exc) {
			errorCount++;
		}
		System.assertEquals(
			1, errorCount,
			'The error was not occurred.'
		);
		Test.stopTest();
	}

	private static SobjectTableServiceAbstract getSobjectTableServiceInstance() {
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
