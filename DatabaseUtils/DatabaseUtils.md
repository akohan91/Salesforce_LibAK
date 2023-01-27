# Table of content

- [Table of content](#table-of-content)
- [Reference Guide](#reference-guide)
  - [SobjectFieldPath](#sobjectfieldpath)
    - [Description](#description)
    - [Constructors](#constructors)
    - [Methods](#methods)

<a name="Reference_Guide">

# Reference Guide

## SobjectFieldPath
<a name="SobjectFieldPath">

### Description
The `'SobjectFieldPath'` class represents the path to the field of Sobject. It effectively allows the necessary data about the target field from the path represented just as a string.

### Constructors
<a name="SobjectFieldPath_Constructors">

The following are constructors for SobjectFieldPath.
- `SobjectFieldPath(String sobjectApi, String path)`
```java
SobjectFieldPath fieldPath = new SobjectFieldPath('Contact', 'Account.Name');
```
- `SobjectFieldPath(SObjectType sObjectType, String path)`
```java
SobjectFieldPath fieldPath = new SobjectFieldPath(Contact.SObjectType, 'Account.Name');
```

### Methods
<a name="SobjectFieldPath_Methods">

The following are methods for SobjectFieldPath. All are instance methods.

- **path** <br>
`path(): String` <br>
Returns field path. Example: Account.Name
```java
System.debug(
    new SobjectFieldPath('Contact', 'Account.Name')
    .path()
); // account.name
```

- **targetReferencePath** <br>
`targetReferencePath(): String` <br>
Returns reference path for target sobject. If sobject is `'Contact'` and path is `'account.name'` it returns `'account.id'`
```java
System.debug(
    new SobjectFieldPath('Contact', 'Account.Name')
    .targetReferencePath()
); // account.id
```

- **targetFieldDescribe** <br>
`targetFieldDescribe(): String` <br>
Returns `'DescribeFieldResult'` for a target field. The target field is the last field of the path. If sobject is `'Contact'` and path is `'Account.Name'` then the target field is `'Name'` of `'Account'`
```java
new SobjectFieldPath('Contact', 'Account.Name')
.targetFieldDescribe()
```