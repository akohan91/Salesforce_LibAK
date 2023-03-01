# Table of content

- [Table of content](#table-of-content)
- [Intro](#intro)
- [Quick Start](#quick-start)
  - [Build a regular query](#build-a-regular-query)
  - [Build an aggregated query](#build-an-aggregated-query)
- [Reference Guide](#reference-guide)
  - [DynamicSOQL](#dynamicsoql)
    - [Constructor](#constructor)
    - [Methods](#methods)
  - [DynamicSOQLFunction](#dynamicsoqlfunction)
    - [Constructor](#constructor-1)
  - [DynamicSOQLConditionBlock](#dynamicsoqlconditionblock)
    - [Constructor](#constructor-2)
    - [Methods](#methods-1)
  - [DynamicSOQLCondition](#dynamicsoqlcondition)
    - [Constructors](#constructors)
  - [DynamicSOQLOrderBy](#dynamicsoqlorderby)
    - [Constructors](#constructors-1)
  - [DynamicSOQLGroupBy](#dynamicsoqlgroupby)
    - [Constructors](#constructors-2)
    - [Methods](#methods-2)

# Intro
<a name="Intro">

DynamicSOQL JavaScript API is almost full mirror of Apex version and allows you to build the JSON representation of your query and then send it to the backend to process. This means you can build your query on the frontend and then process it on the backend, providing a seamless and efficient data retrieval solution.

It also enables you to build your query granularly, meaning you can prepare different parts of the query separately. For example, you can use the DynamicSOQLConditionBlock and DynamicSOQLCondition objects to prepare the JSON representation of your filters, and then build the WHERE clause on the backend.


The library is built in Object Oriented style and contains the next classes:

- **DynamicSOQL** - the main class that represents SOQL.
- **DynamicSOQLCondition** - represents the part of 'WHERE' clause in a base format like `<FieldName> <operator> <value>'`.
- **DynamicSOQLConditionBlock** - used to combine **DynamicSOQLCondition** or nested **DynamicSOQLConditionBlock** and allows to build logical bloks with `OR | AND` keywords.
- **DynamicSOQLFunction** - represent SOQL Functions, for example: `COUNT(Id) alias`.
- **DynamicSOQLGroupBy** - represent `GROUP BY` clause and allows to build Aggregated Query.
- **DynamicSOQLOrderBy** - represent `ORDER BY` clause.

# Quick Start
<a name="Quick_Start">

## Build a regular query
<a name="Build_a_regular_query">

```javascript
const soql = new DynamicSOQL('Account')
    .withField('Id')
    .withField('Name')
    .withConditions(
        new DynamicSOQLConditionBlock('AND')
        .addCondition(new DynamicSOQLCondition('Name', '=', 'Some Account Name'))
    )
    .withOrderBy(new DynamicSOQLOrderBy(['Name', 'Id']))
    .withSubQuery(
        'Contacts',
        new DynamicSOQL('Contact')
        .withField('FirstName')
        .withField('Email')
        .withConditions(
            new DynamicSOQLConditionBlock('AND')
            .addCondition(new DynamicSOQLCondition('Email', '!=', null))
        )
    );
```

## Build an aggregated query
<a name="Build_an_aggregated_query">

```javascript
const soql = new DynamicSOQL('Opportunity')
    .withField('StageName')
    .withFunction(new DynamicSOQLFunction('SUM', 'Amount', 'amount'))
    .withFunction(new DynamicSOQLFunction('COUNT', 'Id', 'oppCount'))
    .withFunction(new DynamicSOQLFunction('AVG', 'Amount', 'avgAmount'))
    .withGroupBy(
        new DynamicSOQLGroupBy(['StageName'])
        .withHaving(
            new DynamicSOQLConditionBlock('AND')
            .addCondition(new DynamicSOQLCondition(
                new DynamicSOQLFunction('SUM','Amount'), '>', 190)
            )
        )
    );
```

<a name="Reference_Guide">

# Reference Guide

## DynamicSOQL
<a name="DynamicSOQL">

### Constructor
<a name="DynamicSOQL_Constructor">

- `DynamicSOQL(sObjectName)`

    **Params:**
    - sObjectName : { String } - Api name of Sobject.

```javascript
const soql = new DynamicSOQL('Account');
```

### Methods
<a name="DynamicSOQL_Methods">

The following are methods for DynamicSOQL. All are instance methods.

- **withField:** adds a field to SELECT statement <br>
`withField(fieldName): DynamicSOQL` <br>

    **Params:**
    - fieldName : { String } - Api name of Sobject Field.
```javascript
new DynamicSOQL('Contact')
.withField('Id')
.withField('Account.Name')
.withField('OwnerId')
```

- **withFunction:** Adds a function to SELECT statement like "COUNT(Id) recordsCount" <br>
`withFunction(function): DynamicSOQL` <br>
    **Params:**
    - function : { DynamicSOQLFunction } - [DynamicSOQLFunction](#dynamicsoqlfunction) object from JS api.
```javascript
new DynamicSOQL('Account')
.withFunction(new DynamicSOQLFunction('COUNT', ''));
```

- **withSubQuery:** Adds a subquery <br>
`withSubQuery(relationshipName,  subQuery): DynamicSOQL` <br>
    **Params:**
    - relationshipName : { String } - Relationship name of Sobject.
    - subQuery : { DynamicSOQL } - [DynamicSOQL](#dynamicsoqlfunction).

```javascript
new DynamicSOQL('Account')
.withField('Name')
.withSubQuery(
    'Contacts',
    new DynamicSOQL('Contact')
        .withField('Id')
)
```

- **withConditions:** adds a condition block to the query<br>
`withConditions(conditionBlock): DynamicSOQL` <br>
    **Params:**
    - conditionBlock : { DynamicSOQLConditionBlock } - [DynamicSOQLConditionBlock](#dynamicsoqlconditionblock) object from JS api.

```javascript
new DynamicSOQL('Account')
.withField('Id')
.withConditions(
    new DynamicSOQLConditionBlock('AND')
    .addCondition(new DynamicSOQLCondition('Name', '=', 'Test'))
    .addCondition(new DynamicSOQLCondition('CreatedDate', '<', new Date()))
)
```

- **withGroupBy:** Adds a GROUP BY statement to the query<br>
`withGroupBy(DynamicSOQLGroupBy groupBy): DynamicSOQL` <br>
    **Params:**
    - groupBy : { DynamicSOQLGroupBy } - [DynamicSOQLGroupBy](#dynamicsoqlgroupby) object from JS api.

```javascript
new DynamicSOQL('Opportunity')
.withField('StageName')
.withFunction(new DynamicSOQLFunction('SUM', 'Amount', 'amount'))
.withGroupBy(
    new DynamicSOQLGroupBy(['StageName'])
    .withHaving(
        new DynamicSOQLConditionBlock('AND')
        .addCondition(new DynamicSOQLCondition(
            new DynamicSOQLFunction('SUM','Amount'), '>', 190)
        )
    )
)
```

- **withOrderBy:** adds the ORDER BY statement to the query<br>
`withOrderBy(orderBy): DynamicSOQL` <br>
    **Params:**
    - orderBy : { DynamicSOQLOrderBy } - [DynamicSOQLOrderBy](#dynamicsoqlorderby) object from JS api.

```javascript
new DynamicSOQL('Account')
.withField('Name')
.withOrderBy(new DynamicSOQLOrderBy(['Name']))
```

- **withOffset:** adds OFFSET statement to SOQL<br>
`withOffset(offsetNumber): DynamicSOQL` <br>

    **Params:**
    - offsetNumber : { Number }

```javascript
new DynamicSOQL('Account')
.withField('Id')
.withOffset(0)
.withLimit(10)
```

- **withLimit:** adds LIMIT statement to SOQL<br>
`withLimit(limitNumber): DynamicSOQL` <br>
    **Params:**
    - limitNumber : { Number }

```javascript
new DynamicSOQL('Account')
.withField('Id')
.withOffset(0)
.withLimit(10)
```

## DynamicSOQLFunction
<a name="DynamicSOQLFunction">

### Constructor
<a name="DynamicSOQLFunction_Constructors">

- `DynamicSOQLFunction(functionName, fieldName, alias)`
    **Params:**
    - functionName : { String }
    - fieldName : { String }
    - alias : { String }

```javascript
const soqlFunction = new DynamicSOQLFunction('COUNT', 'Id', 'recordsCount');
```

## DynamicSOQLConditionBlock
<a name="DynamicSOQLConditionBlock">

### Constructor
<a name="DynamicSOQLConditionBlock_Constructor">


- `DynamicSOQLConditionBlock(operator)`
    **Params:**
    - operator : { String } - Could be `"AND|OR"`

```javascript
const conditionBlock = new DynamicSOQLConditionBlock('AND')
```

### Methods
<a name="DynamicSOQLConditionBlock_Methods">

The following are methods for DynamicSOQL. All are instance methods.

- **addCondition:** adds a condition to the current block<br>
`addCondition(condition): DynamicSOQLConditionBlock` <br>
    **Params:**
    - condition : { DynamicSOQLCondition } - [DynamicSOQLCondition](#dynamicsoqlcondition) object from JS api.

```javascript
const conditionBlock = new DynamicSOQLConditionBlock('AND')
.addCondition(new DynamicSOQLCondition('Name', '=', 'Test_1'));
```

- **addConditionBlock:** adds new condition block that will be added to the current one. It allow to build complex conditions like `(condition OR condition) AND condition`<br>
`addConditionBlock(conditionBlock): DynamicSOQLConditionBlock` <br>
    **Params:**
    - conditionBlock : { DynamicSOQLConditionBlock } - [DynamicSOQLConditionBlock](#dynamicsoqlconditionblock) object from JS api.

```javascript
const conditionBlock = new DynamicSOQLConditionBlock('AND')
.addCondition(new DynamicSOQLCondition('Name', '=', 'Test1'))
.addConditionBlock(
    new DynamicSOQLConditionBlock('OR')
    .addCondition(new DynamicSOQLCondition('Phone', '=', '12345'))
    .addCondition(new DynamicSOQLCondition('Phone', '=', '123456'))
);
```

- **switchOperator** Changes the operator. Could be either `"OR|AND"`<br>
`switchOperator(operator): DynamicSOQLConditionBlock`
    **Params:**
    - operator : { String }

```javascript
const conditionBlock = new DynamicSOQLConditionBlock('AND')
conditionBlock.switchOperator('OR');
```

## DynamicSOQLCondition
<a name="DynamicSOQLCondition">

### Constructors
<a name="DynamicSOQLCondition_Constructors">

- `DynamicSOQLCondition(fieldName, operator, value)`
    **Params:**
    - fieldName : { String } - Sobject field api name
    - operator : { String } - SOQL condition operators like `=|!=|<|<=|>|>=|LIKE|IN|NOT IN|INCLUDES|EXCLUDES`
    - value : { Any } - value for condition. It could be any possible values like primitives, arrays of primitives or another DynamicSOQL

```javascript
const booleanCondition  = new DynamicSOQLCondition('isActive', '=', true);
const numberCondition   = new DynamicSOQLCondition('Amount', '>=', 100);
const dateCondition     = new DynamicSOQLCondition('CreatedDate', '>=', new Date());
const functionCondition = new DynamicSOQLCondition(new DynamicSOQLFunction('COUNT', 'Id'), '>', 10);
const stringCondition   = new DynamicSOQLCondition('Name', '=', "It's a string");
const arrayCondition    = new DynamicSOQLCondition('Name', 'IN', ['It\'s a string', 'It\'s another string']);
const soqlAsCondition   = new DynamicSOQLCondition('AccountId', 'IN',
    new DynamicSOQL('Account')
    .withField('Id')
    .withConditions(
        new DynamicSOQLConditionBlock('AND')
        .addCondition(new DynamicSOQLCondition('Industry', '=', 'Government'))
    )
);
```

## DynamicSOQLOrderBy
<a name="DynamicSOQLOrderBy">

### Constructors
<a name="DynamicSOQLOrderBy_Constructors">

- `DynamicSOQLOrderBy(List<String> orderByFields, Boolean isDESC, Boolean isNullsFirst)`
    **Params:**
    - orderByFields : { String[] } - Sobject field api names
    - isDESC : { Boolean } - flag to set ordering direction.
    - isNullsFirst : { Boolean } - flag to set ordering of nulls

```javascript
const orderBy = new DynamicSOQLOrderBy(['Name', 'Id'], true, true);
```

## DynamicSOQLGroupBy
<a name="DynamicSOQLGroupBy">

### Constructors
<a name="DynamicSOQLGroupBy_Constructors">

The following are constructors for DynamicSOQL.

- `DynamicSOQLGroupBy(List<String> fieldGroupByList)`
    **Params:**
    - orderByFields : { String[] } - Sobject field api names
```javascript
const groupBy = new DynamicSOQLGroupBy(['StageName']);
```

### Methods
<a name="DynamicSOQLGroupBy_Methods">

The following are methods for DynamicSOQL. All are instance methods.

- **withHaving:** adds HAVING clause to the GROUP BY clause<br>
`withHaving(DynamicSOQLConditionBlock conditionBlock): DynamicSOQLGroupBy`
    **Params:**
    - conditionBlock : { DynamicSOQLConditionBlock } - [DynamicSOQLConditionBlock](#dynamicsoqlconditionblock) object from JS api.

```javascript
const groupBy = new DynamicSOQLGroupBy(['Name'])
.withHaving(
    new DynamicSOQLConditionBlock('AND')
    .addCondition(new DynamicSOQLCondition(new DynamicSOQLFunction('COUNT', 'Name'), '>', 10))
);
```