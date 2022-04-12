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
    Database.query(
        new DynamicSOQL('Contact')
        .withField('Id')
        .withField('FirstName')
        .withField('LastName')
        .withConditions(
            new DynamicSOQLConditionBlock('AND')
            .addCondition(new DynamicSOQLCondition('LastName', '=:', 'name'))
        ).toString()
    )
);

System.debug(
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
);