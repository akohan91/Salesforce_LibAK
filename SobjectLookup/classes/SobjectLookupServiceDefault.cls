public with sharing class SobjectLookupServiceDefault extends SobjectLookupServiceAbstract{
	
	/* PUBLIC METHODS */

	/**
	 * @description Builds a new instance of SobjectLookupServiceAbstract.
	 * Was added to have an ability use the 'Decorator Pattern'
	 * @return   {SobjectLookupServiceAbstract}
	 */
	override public SobjectLookupServiceAbstract createService(String inputJSON) {
		return (SobjectLookupServiceAbstract)JSON.deserialize(inputJSON, SobjectLookupServiceDefault.class);
	}

	/**
	 * @description Returns the list of Sobject records
	 * @return   { List<SObject> }
	 */
	override public List<SObject> sobjectRecords() {
		DynamicSOQL soql = this.buildGeneralSoql()
			.withField(this.titleFieldName)
			.withLimit(this.limitRecords)
			.withOffset(this.offsetRecords);
		return Database.query(soql.toString());
	}
	
	/**
	 * @description Returns the number of Sobject records.
	 * @return   { Integer }
	 */
	override public Integer recordsCount() {
		DynamicSOQL soql = this.buildGeneralSoql().withFunction(new DynamicSOQLFunction('COUNT'));

		return Database.countQuery(soql.toString());
	}

	/* PRIVATE METHODS */

	private DynamicSOQL buildGeneralSoql() {
		DynamicSOQLConditionBlock conditionBlock = new DynamicSOQLConditionBlock('AND')
			.addConditionBlock(this.buildSearchConditionBlock());
		if (this.defaultConditionBlock != null) {
			conditionBlock.addConditionBlock(this.defaultConditionBlock);
		}
		
		return new DynamicSOQL(this.sobjectName)
			.withConditions(conditionBlock);
	}

	private DynamicSOQLConditionBlock buildSearchConditionBlock() {
		DynamicSOQLConditionBlock searchConditions = new DynamicSOQLConditionBlock('OR');
		for (String fieldName : this.searchedByFields) {
			searchConditions.addCondition(
				new DynamicSOQLCondition(fieldName, 'LIKE', ('%' + this.searchTerm + '%'))
			);
		}
		return searchConditions;
	}
}
