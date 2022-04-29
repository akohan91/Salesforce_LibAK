# Intro

The DynamicSOQL library helps to build SOQL strings with more declarative style than via native apex code.

The library is built in Object Oriented style and contains the next classes:

- **DynamicSOQL** - the main class that represents SOQL.
- **DynamicSOQLCondition** - represents the part of 'WHERE' clause in a base format like `<FieldName> <operator> <value>'`.
- **DynamicSOQLConditionBlock** - used to combine **DynamicSOQLCondition** or nested **DynamicSOQLConditionBlock** and allows to build logical bloks with `OR | AND` keywords.
- **DynamicSOQLFunction** - represent SOQL Functions, for example: `COUNT(Id) alias`.
- **DynamicSOQLGoupBy** - represent `GROUP BY` clause and allows to build Aggregated Query.
- **DynamicSOQLOrderBy** - represent `ORDER BY` clause.

# Quick Start

## Build a regular query

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
/* The output (add line breaks manually):
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

## Build a Aggregated query

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

/* The output (add line breaks manually):
	SELECT StageName,
		SUM(Amount) amount,
		COUNT(Id) oppCount,
		AVG(Amount) avgAmount
	FROM Opportunity
	GROUP BY StageName
		HAVING (SUM(Amount) > 190)
*/
```