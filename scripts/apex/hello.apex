// List<Contact> cons = new List<Contact>();

// for (Integer i = 0; i < 10; i++) {
//     cons.add(new Contact(
//         FirstName = 'FiersName' + ' ' + i,
//         LastName = 'LastName' + ' ' + i
//     ));
// }

// Database.insert(cons);

String name = 'LastName 1';
System.debug(
    // Database.query(
        new DynamicSOQL('Account')
        .withField('Id')
        .withField('Name')
        .withSubQuery(
            'Contacts',
            new DynamicSOQL('Contact')
            .withField('Id')
            .withField('FirstName')
        )
        .withConditions(
            new DynamicSOQLConditionBlock('AND')
            .addCondition(new DynamicSOQLCondition('Phone', '=', '12345'))
        )
        .withOffset(100)
        .withLimit(10)
    // )
);


String jsonString = '{ "subQueries": { "Contacts": { "subQueries": {}, "sObjectName": "Contact", "fields": ["Id", "FirstName"], "conditionBlock": { "operator": "AND", "conditions": [ { "value": "name", "operator": "=", "isString": true, "fieldName": "LastName" } ], "blocks": [] } } }, "sObjectName": "Account", "fields": ["Id", "Name"], "conditionBlock": { "operator": "AND", "conditions": [ { "value": "Test String", "operator": "=", "isString": true, "fieldName": "Name" } ], "blocks": [] } }';
DynamicSOQL soql = (DynamicSOQL)JSON.deserialize(jsonString, DynamicSOQL.class);
System.debug(soql);