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
    // JSON.serialize(
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
            .addCondition(new DynamicSOQLCondition('Name', '=', 'Sample Account for Entitlements'))
        )
        .withOffset(0)
        .withOrderBy(new DynamicSOQLOrderBy(new List<String>{'Industry'}))
        .withLimit(10)
        .infoToFLSCheck()
    // )
    // )
);


String jsonString = '{ "subQueries": { "Contacts": { "subQueries": {}, "sObjectName": "Contact", "fields": ["Id", "FirstName"], "conditionBlock": { "operator": "AND", "conditions": [ { "value": "name", "operator": "=", "isString": true, "fieldName": "LastName" } ], "blocks": [] } } }, "sObjectName": "Account", "fields": ["Id", "Name"], "conditionBlock": { "operator": "AND", "conditions": [ { "value": "Test String", "operator": "=", "isString": true, "fieldName": "Name" } ], "blocks": [] } }';
DynamicSOQL soql = (DynamicSOQL)JSON.deserialize(jsonString, DynamicSOQL.class);
System.debug(soql);


DynamicSOQLOrderBy orderBy = new DynamicSOQLOrderBy(new List<String>{'Industry'});
orderBy.fieldsList().remove(0);

System.debug(new List<String>{'test'} == new List<String>{'test '});