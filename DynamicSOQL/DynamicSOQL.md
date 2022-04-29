# Table of content

1. [Intro](#Intro)
2. [Quick Start](#Quick_Start)
    - [Build a regular query](#Build_a_regular_query)
    - [Build an aggregated query](#Build_an_aggregated_query)
3. [Reference Guide](#Reference_Guide)
    - [DynamicSOQL](#DynamicSOQL)
        - [Constructors](#DynamicSOQL_Constructors)
        - [Methods](#DynamicSOQL_Methods)

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

- **withFunction** <br>
`withFunction(DynamicSOQLFunction function): DynamicSOQL` <br>
Adds a function to SELECT statement like "COUNT(Id) recordsCount"

- **withSubQuery** <br>
`withSubQuery(String relationshipName, DynamicSOQL subQuery): DynamicSOQL` <br>
Adds a subquery

- **withConditions** <br>
`withConditions(DynamicSOQLConditionBlock conditionBlock): DynamicSOQL` <br>
Adds a condition block to the query

- **withGroupBy** <br>
`withGroupBy(DynamicSOQLGoupBy groupBy): DynamicSOQL` <br>
Adds a GROUP BY statement to the query

- **withOrderBy** <br>
`withOrderBy(DynamicSOQLOrderBy orderBy): DynamicSOQL` <br>
Adds a ORDER BY statement to the query

- **withOffset** <br>
`withOffset(Integer offsetNumber): DynamicSOQL` <br>
Adds OFFSET statement to SOQL

- **withLimit** <br>
`withLimit(Integer limitNumber): DynamicSOQL` <br>
Adds LIMIT statement to SOQL

- **infoToFLSCheck** <br>
`infoToFLSCheck(): Map<String, Set<String>>` <br>
Returns the Map in format: `sObjectApiName => Set<String>{fieldApiName}`

- **toString** <br>
`toString(): Map<String, Set<String>>` <br>
Builds a SOQL string