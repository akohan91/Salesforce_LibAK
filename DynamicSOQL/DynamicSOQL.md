# Table of content

1. [Intro](#Intro)
2. [Quick Start](#Quick_Start)
    - [Build a regular query](#Build_a_regular_query)
    - [Build an aggregated query](#Build_an_aggregated_query)
3. [Reference Guide](#Reference_Guide)
    - [DynamicSOQL](#DynamicSOQL)
        - [Constructors](#DynamicSOQL_Constructors)
        - [Methods](#DynamicSOQL_Methods)
    - [DynamicSOQLFunction](#DynamicSOQLFunction)
        - [Constructors](#DynamicSOQLFunction_Constructors)
        - [Methods](#DynamicSOQLFunction_Methods)
    - [DynamicSOQLConditionBlock](#DynamicSOQLConditionBlock)
        - [Constructors](#DynamicSOQLConditionBlock_Constructors)
        - [Methods](#DynamicSOQLConditionBlock_Methods)
    - [DynamicSOQLCondition](#DynamicSOQLCondition)
        - [Constructors](#DynamicSOQLCondition_Constructors)
        - [Methods](#DynamicSOQLCondition_Methods)
    - [DynamicSOQLOrderBy](#DynamicSOQLOrderBy)
        - [Constructors](#DynamicSOQLOrderBy_Constructors)
        - [Methods](#DynamicSOQLOrderBy_Methods)
    - [DynamicSOQLGroupBy](#DynamicSOQLGroupBy)
        - [Constructors](#DynamicSOQLGroupBy_Constructors)
        - [Methods](#DynamicSOQLGroupBy_Methods)

# Intro
<a name="Intro">

The DynamicSOQL library helps to build SOQL strings with more declarative style than via native apex code.

The library is built in Object Oriented style and contains the next classes:

- **DynamicSOQL** - the main class that represents SOQL.
- **DynamicSOQLCondition** - represents the part of 'WHERE' clause in a base format like `<FieldName> <operator> <value>'`.
- **DynamicSOQLConditionBlock** - used to combine **DynamicSOQLCondition** or nested **DynamicSOQLConditionBlock** and allows to build logical bloks with `OR | AND` keywords.
- **DynamicSOQLFunction** - represent SOQL Functions, for example: `COUNT(Id) alias`.
- **DynamicSOQLGoupBy** - represent `GROUP BY` clause and allows to build Aggregated Query.
- **DynamicSOQLOrderBy** - represent `ORDER BY` clause.

# Quick Start
<a name="Quick_Start">

## Build a regular query
<a name="Build_a_regular_query">

```java
DynamicSOQL soql = new DynamicSOQL('Account')
.withField('Id')
.withField('Name')
.withConditions(
    new DynamicSOQLConditionBlock('AND')
    .addCondition(new DynamicSOQLCondition('Name', '=', 'Some Account Name'))
)
.withOrderBy(new DynamicSOQLOrderBy(new List<String>{'Name', 'Id'}))
.withSubQuery(
    'Contacts',
    new DynamicSOQL('Contact')
    .withField('FirstName')
    .withField('Email')
    .withConditions(
        new DynamicSOQLConditionBlock('AND')
        .addCondition(new DynamicSOQLCondition('Email', '!=', (String)null))
    )
);

System.debug(soql.toString());
/* The output (line breaks was added manually):
    SELECT Id,Name,(
        SELECT FirstName,Email
        FROM Contacts
        WHERE (Email != null)
    )
    FROM Account
    WHERE (Name = 'Some Account Name')
    ORDER BY Name,Id ASC NULLS LAST
*/
```

## Build an aggregated query
<a name="Build_an_aggregated_query">

```java
DynamicSOQL soql = new DynamicSOQL('Opportunity')
.withField('StageName')
.withFunction(new DynamicSOQLFunction('SUM', 'Amount', 'amount'))
.withFunction(new DynamicSOQLFunction('COUNT', 'Id', 'oppCount'))
.withFunction(new DynamicSOQLFunction('AVG', 'Amount', 'avgAmount'))
.withGroupBy(
    new DynamicSOQLGoupBy(new List<String>{'StageName'})
    .withHaving(
        new DynamicSOQLConditionBlock('AND')
        .addCondition(new DynamicSOQLCondition(
            new DynamicSOQLFunction('SUM','Amount'), '>', 190)
        )
    )
);

System.debug(soql.toString());

/* The output (line breaks was added manually):
    SELECT StageName,
        SUM(Amount) amount,
        COUNT(Id) oppCount,
        AVG(Amount) avgAmount
    FROM Opportunity
    GROUP BY StageName
        HAVING (SUM(Amount) > 190)
*/
```

<a name="Reference_Guide">

# Reference Guide

## DynamicSOQL
<a name="DynamicSOQL">

### Constructors
<a name="DynamicSOQL_Constructors">

The following are constructors for DynamicSOQL.
- `DynamicSOQL(String sObjectName)`
```java
DynamicSOQL soql = new DynamicSOQL('Account');
```

### Methods
<a name="DynamicSOQL_Methods">

The following are methods for DynamicSOQL. All are instance methods.

- **withField** <br>
`withField(String fieldName): DynamicSOQL` <br>
Adds a field to SELECT statement
```java
System.debug(
    new DynamicSOQL('Account')
    .withField('Id')
    .withField('Name')
    .withField('OwnerId')
); // SELECT Id,Name,OwnerId FROM Account
```

- **withFunction** <br>
`withFunction(DynamicSOQLFunction function): DynamicSOQL` <br>
Adds a function to SELECT statement like "COUNT(Id) recordsCount"
```java
System.debug(
    new DynamicSOQL('Account')
    .withFunction(new DynamicSOQLFunction('COUNT', ''))
); // SELECT COUNT() FROM Account
```

- **withSubQuery** <br>
`withSubQuery(String relationshipName, DynamicSOQL subQuery): DynamicSOQL` <br>
Adds a subquery

```java
System.debug(
    new DynamicSOQL('Account')
    .withField('Name')
    .withSubQuery(
        'Contacts',
        new DynamicSOQL('Contact')
        .withField('Id')
    )
); // SELECT Name,(SELECT Id FROM Contacts) FROM Account
```

- **withConditions** <br>
`withConditions(DynamicSOQLConditionBlock conditionBlock): DynamicSOQL` <br>
Adds a condition block to the query

```java
System.debug(
    new DynamicSOQL('Account')
    .withField('Id')
    .withConditions(
        new DynamicSOQLConditionBlock('AND')
        .addCondition(new DynamicSOQLCondition('Name', '=', 'Test'))
        .addCondition(new DynamicSOQLCondition('CreatedDate', '>', Date.newInstance(2022, 01, 01)))
    )
); // SELECT Id FROM Account WHERE (Name = 'Test' AND CreatedDate > 2022-01-01)
```

- **withGroupBy** <br>
`withGroupBy(DynamicSOQLGoupBy groupBy): DynamicSOQL` <br>
Adds a GROUP BY statement to the query

```java
System.debug(
    new DynamicSOQL('Opportunity')
    .withField('StageName')
    .withFunction(new DynamicSOQLFunction('SUM', 'Amount', 'amount'))
    .withGroupBy(
        new DynamicSOQLGoupBy(new List<String>{'StageName'})
        .withHaving(
            new DynamicSOQLConditionBlock('AND')
            .addCondition(new DynamicSOQLCondition(
                new DynamicSOQLFunction('SUM','Amount'), '>', 190)
            )
        )
    )
); // SELECT StageName,SUM(Amount) amount FROM Opportunity GROUP BY StageName HAVING (SUM(Amount) > 190)
```

- **withOrderBy** <br>
`withOrderBy(DynamicSOQLOrderBy orderBy): DynamicSOQL` <br>
Adds a ORDER BY statement to the query

```java
System.debug(
    new DynamicSOQL('Account')
    .withField('Name')
    .withOrderBy(new DynamicSOQLOrderBy(new List<String>{'Name'}))
); // SELECT Name FROM Account ORDER BY Name ASC NULLS LAST
```

- **withOffset** <br>
`withOffset(Integer offsetNumber): DynamicSOQL` <br>
Adds OFFSET statement to SOQL

```java
System.debug(
    new DynamicSOQL('Account')
    .withField('Id')
    .withOffset(0)
    .withLimit(10)
); // SELECT Id FROM Account LIMIT 10 OFFSET 0
```

- **withLimit** <br>
`withLimit(Integer limitNumber): DynamicSOQL` <br>
Adds LIMIT statement to SOQL

```java
System.debug(
    new DynamicSOQL('Account')
    .withField('Id')
    .withOffset(0)
    .withLimit(10)
); // SELECT Id FROM Account LIMIT 10 OFFSET 0
```

- **infoToFLSCheck** <br>
`infoToFLSCheck(): Map<String, Set<String>>` <br>
Returns the Map in format: `sObjectApiName => Set<String>{fieldApiName}`

```java
System.debug(
    new DynamicSOQL('Account')
    .withFunction(new DynamicSOQLFunction('COUNT', 'Id'))
    .withField('Name')
    .withSubQuery(
        'Contact',
        new DynamicSOQL('Contact')
        .withField('Id')
        .withField('FirstName')
    )
    .withConditions(
        new DynamicSOQLConditionBlock('AND')
        .addCondition(new DynamicSOQLCondition('Phone', '=', '12345'))
    )
    .withOrderBy(new DynamicSOQLOrderBy(new List<String>{'Industry'}))
    .infoToFLSCheck()
);

/*
{
    Account={Id, Industry, Name, Phone},
    Contact={FirstName, Id}
}
*/
```

- **toString** <br>
`toString(): String` <br>
Builds a SOQL string

```java
new DynamicSOQL('Account')
.withField('Id')
.withSubQuery('Contacts', new DynamicSOQL('Contact').withField('Id'))
.toString(); // SELECT Id,(SELECT Id FROM Contacts) FROM Account
```

## DynamicSOQLFunction
<a name="DynamicSOQLFunction">

### Constructors
<a name="DynamicSOQLFunction_Constructors">

The following are constructors for DynamicSOQL.
- `DynamicSOQLFunction(String functionName)`
```java
DynamicSOQLFunction function = new DynamicSOQLFunction('COUNT');
System.debug(function.toString()); // COUNT()
```
- `DynamicSOQLFunction(String functionName, String fieldName)`
```java
DynamicSOQLFunction function = new DynamicSOQLFunction('COUNT', 'Id');
System.debug(function.toString()); // COUNT(Id)
```
- `DynamicSOQLFunction(String functionName, String fieldName, String alias)`
```java
DynamicSOQLFunction function = new DynamicSOQLFunction('COUNT', 'Id', 'recordsCount');
System.debug(function.toString()); // COUNT(Id) recordsCount
```

### Methods
<a name="DynamicSOQLFunction_Methods">

The following are methods for DynamicSOQL. All are instance methods.

- **fieldApiName** <br>
`fieldApiName(): String` <br>
Returns the field api name that is used in a formula.

```java
new DynamicSOQLFunction('COUNT', 'Id', 'alias')
.fieldApiname() // Id
```

- **toString** <br>
`toString(): String` <br>
Builds a SOQL function string like `COUNT(Id) recordsCount`

```java
new DynamicSOQLFunction('COUNT', 'Id', 'alias')
.toString() // COUNT(Id) alias
```

## DynamicSOQLConditionBlock
<a name="DynamicSOQLConditionBlock">

### Constructors
<a name="DynamicSOQLConditionBlock_Constructors">

The following are constructors for DynamicSOQL.

- `DynamicSOQLConditionBlock(String operator)`

```java
DynamicSOQLConditionBlock conditionBlock = new DynamicSOQLConditionBlock('AND')
```

### Methods
<a name="DynamicSOQLConditionBlock_Methods">

The following are methods for DynamicSOQL. All are instance methods.

- **addCondition** <br>
`addCondition(DynamicSOQLCondition condition): DynamicSOQLConditionBlock` <br>
Adds a condition to the current block

```java
DynamicSOQLConditionBlock conditionBlock = new DynamicSOQLConditionBlock('OR')
.addCondition(new DynamicSOQLCondition('Name', '=', 'Test_1'));

System.debug(conditionBlock); // (Name = 'Test_1')

conditionBlock
.addCondition(new DynamicSOQLCondition('Name', '=', 'Test_2'));
System.debug(conditionBlock); // (Name = 'Test_1' OR Name = 'Test_2')
```

- **addConditionBlock** <br>
`addConditionBlock(DynamicSOQLConditionBlock conditionBlock): DynamicSOQLConditionBlock` <br>
Adds new condition block that will be added to the current one. It allow to build complex conditions like
`(condition OR condition) AND condition`

```java
DynamicSOQLConditionBlock conditionBlock = new DynamicSOQLConditionBlock('AND')
.addCondition(new DynamicSOQLCondition('Name', '=', 'Test1'))
.addConditionBlock(
    new DynamicSOQLConditionBlock('OR')
    .addCondition(new DynamicSOQLCondition('Phone', '=', '12345'))
    .addCondition(new DynamicSOQLCondition('Phone', '=', '123456'))
);

System.debug(conditionBlock); // ((Phone = '12345' OR Phone = '123456') AND Name = 'Test1')
```

- **switchOperator** <br>
`switchOperator(String operator): DynamicSOQLConditionBlock`
Changes the operator. Could be either `OR | AND`

```java
DynamicSOQLConditionBlock conditionBlock = new DynamicSOQLConditionBlock('AND')
.addCondition(new DynamicSOQLCondition('Phone', '=', '12345'))
.addCondition(new DynamicSOQLCondition('Phone', '=', '123456'));

System.debug(conditionBlock); // (Phone = '12345' AND Phone = '123456')
conditionBlock.switchOperator('OR');
System.debug(conditionBlock); // (Phone = '12345' OR Phone = '123456')
```

- **fieldsApiNames** <br>
`fieldsApiNames(): Set<String>` <br>
Returns all field api names from DynamicSOQLCondition and DynamicSOQLConditionBlock

```java
DynamicSOQLConditionBlock conditionBlock = new DynamicSOQLConditionBlock('AND')
.addCondition(new DynamicSOQLCondition('Phone', '=', '121345'))
.addCondition(new DynamicSOQLCondition('FirstName', '=', 'Test'))
.addCondition(new DynamicSOQLCondition('LastName', '=', 'Test'));

conditionBlock.fieldsApiNames(); // {'Phone', 'FirstName', 'LastName'}
```

- **toString** <br>
`toString(): String` <br>
Builds a Dynamic SOQL Condition Block string for WHERE statement

## DynamicSOQLCondition
<a name="DynamicSOQLCondition">

### Constructors
<a name="DynamicSOQLCondition_Constructors">

The following are constructors for DynamicSOQL.

- `DynamicSOQLCondition(String fieldName, String operator, Object value)`

```java
DynamicSOQLCondition booleanCondition = new DynamicSOQLCondition('isActive', '=', true);
DynamicSOQLCondition numberCondition = new DynamicSOQLCondition('Amount', '>=', 100);
```

- `DynamicSOQLCondition(DynamicSOQLFunction function, String operator, Object value)`

```java
DynamicSOQLCondition condition = new DynamicSOQLCondition(
    new DynamicSOQLFunction('COUNT', 'Amount'),
    '>',
    100
);
```

- `DynamicSOQLCondition(String fieldName, String operator, Datetime value)`

```java
DynamicSOQLCondition condition = new DynamicSOQLCondition('CreatedDate', '>', Datetime.newInstance(2022, 01, 01, 01, 01, 01));
```

- `DynamicSOQLCondition(String fieldName, String operator, Date value)`

```java
DynamicSOQLCondition condition = new DynamicSOQLCondition('CreatedDate', '>', Date.newInstance(2022, 01, 01));
```

- `DynamicSOQLCondition(String fieldName, String operator, String value)`

```java
DynamicSOQLCondition stringCondition = new DynamicSOQLCondition('Name', '=', 'It\'s a string');

Set<Id> someVariable = new Set<Id>{'id_1','id_2','id_3'}
DynamicSOQLCondition variableCondition = new DynamicSOQLCondition('Id', 'IN:', 'someVariable');
```


### Methods
<a name="DynamicSOQLCondition_Methods">

The following are methods for DynamicSOQL. All are instance methods.

- **fieldApiName** <br>
`fieldApiName(): String` <br>
Returns the field api name that is used in a condition.

- **toString** <br>
`toString(): String` <br>
Builds a SOQL condition string like `Name = 'Andrew'`

## DynamicSOQLOrderBy
<a name="DynamicSOQLOrderBy">

### Constructors
<a name="DynamicSOQLOrderBy_Constructors">

The following are constructors for DynamicSOQL.

- `DynamicSOQLOrderBy(List<String> orderByFields)`
```java
DynamicSOQLOrderBy orderBy = new DynamicSOQLOrderBy(new List<String>{'Name', 'Id'});
```

- `DynamicSOQLOrderBy(List<String> orderByFields, Boolean isDESC)`
```java
DynamicSOQLOrderBy orderBy = new DynamicSOQLOrderBy(new List<String>{'Name', 'Id'}, true);
```

- `DynamicSOQLOrderBy(List<String> orderByFields, Boolean isDESC, Boolean isNullsFirst)`
```java
DynamicSOQLOrderBy orderBy = new DynamicSOQLOrderBy(new List<String>{'Name', 'Id'}, true, true);
```

### Methods
<a name="DynamicSOQLOrderBy_Methods">

The following are methods for DynamicSOQL. All are instance methods.

- **fieldsApiNames** <br>
`fieldsApiNames(): Set<String>` <br>
Returns list of fields that are used in ORDER BY Statement

- **toString** <br>
`toString(): String` <br>
Returns ORDER BY statement like: "ORDER BY Name ASC NULLS LAST"

## DynamicSOQLGroupBy
<a name="DynamicSOQLGroupBy">

### Constructors
<a name="DynamicSOQLGroupBy_Constructors">

The following are constructors for DynamicSOQL.

- `DynamicSOQLGoupBy(List<String> fieldGroupByList)`
```java
DynamicSOQLGoupBy groupBy = new DynamicSOQLGoupBy(new List<String>{'StageName'});
```

### Methods
<a name="DynamicSOQLGroupBy_Methods">

The following are methods for DynamicSOQL. All are instance methods.

- **fieldsApiNames** <br>
`fieldsApiNames(): Set<String>` <br>
Returns list of fields that are used in GROUP BY Statement

- **withHaving** <br>
`withHaving(DynamicSOQLConditionBlock conditionBlock): DynamicSOQLGoupBy` <br>
Adds HAVING clause to the GROUP BY clause

- **toString** <br>
`toString(): String` <br>
Builds a GROUP BY part of SOQL string
