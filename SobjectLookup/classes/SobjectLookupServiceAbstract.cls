/**
 * @author Andrei Kakhanouski <akohan91@gmail.com>
 */
public abstract class SobjectLookupServiceAbstract {
	@TestVisible protected String sobjectName;
	@TestVisible protected List<String> searchedByFields;
	@TestVisible protected String searchTerm;
	@TestVisible protected String titleFieldName;
	@TestVisible protected DynamicSOQLConditionBlock defaultConditionBlock;
	@TestVisible protected Integer limitRecords;
	@TestVisible protected Integer offsetRecords;

	/* ABSTRACT METHODS */

	/**
	 * @description Builds a new instance of SobjectLookupServiceAbstract.
	 * Was added to have an ability use the 'Decorator Pattern'
	 * @return   {SobjectLookupServiceAbstract}
	 */
	abstract public SobjectLookupServiceAbstract createService(String inputJSON);

	/**
	 * @description Returns the list of Sobject records
	 * @return   { List<SObject> }
	 */
	abstract public List<SObject> sobjectRecords();

	/**
	 * @description Returns the number of Sobject records.
	 * @return   { Integer }
	 */
	abstract public Integer recordsCount();
}
