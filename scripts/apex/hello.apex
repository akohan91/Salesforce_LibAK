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
    new DynamicSOQL('Contact')
    .withField('Id')
    .withConditions(
        new DynamicSOQLConditionBlock('AND')
        .addCondition(new DynamicSOQLCondition('LastName', '=', (String)null))
    ).toString()
);

System.debug(
    JSON.serialize(
        new DynamicSOQL('Account')
        .withField('Id')
        .withField('Name')
        .withSubQuery(
            'Contacts',
            new DynamicSOQL('Contact')
            .withField('Id')
            .withField('FirstName')
            .withConditions(
                new DynamicSOQLConditionBlock('AND')
                .addCondition(new DynamicSOQLCondition('Name', '=', 'Test String'))
            )
        )
        .withConditions(
            new DynamicSOQLConditionBlock('AND')
            .addCondition(new DynamicSOQLCondition('LastName', '=:', 'name'))
        )
    )
);


String jsonString = '{ "subQueries": { "Contacts": { "subQueries": {}, "sObjectName": "Contact", "fields": ["Id", "FirstName"], "conditionBlock": { "operator": "AND", "conditions": [ { "value": "Test String", "operator": "=", "isString": true, "fieldName": "Name" } ], "blocks": [] } } }, "sObjectName": "Account", "fields": ["Id", "Name"], "conditionBlock": { "operator": "AND", "conditions": [ { "value": "name", "operator": "=:", "isString": false, "fieldName": "LastName" } ], "blocks": [] } }';
DynamicSOQL soql = (DynamicSOQL)JSON.deserialize(jsonString, DynamicSOQL.class);
System.debug(soql);