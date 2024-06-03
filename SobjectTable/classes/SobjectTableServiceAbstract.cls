/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
public abstract class SobjectTableServiceAbstract {
	@TestVisible protected String sobjectName;
	@TestVisible protected List<String> selectFields;
	@TestVisible protected DynamicSOQLConditionBlock conditionBlock;
	@TestVisible protected DynamicSOQLOrderBy orderBy;
	@TestVisible protected Integer limitRecords;
	@TestVisible protected Integer offsetRecords;

	/* ABSTRACT METHODS */

	/**
	 * @description Builds a new instance of SobjectTableServiceAbstract.
	 * Was added to have an ability use the 'Decorator Pattern'
	 * @return   {SobjectTableServiceAbstract}
	 */
	abstract public SobjectTableServiceAbstract createService(String inputJSON);

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

	/**
	 * @description Returns the list of field paths that have ADDRESS display type
	 * @return   { List<String> }
	 */
	abstract public List<String> addressFieldPaths();

	/**
	 * @description Returns the list of field paths that have ID or REFERENCE display type
	 * @return   { List<String> }
	 */
	abstract public List<String> referenceFieldPaths();

	/**
	 * @description Returns the list of LWC dataTable columns
	 * @return   { List<Object> }
	 */
	abstract public List<Object> dataTableColumns();
}
