/**
 * @author Andrei Kakhanouski <akohan91@gmail.com>
 */
public abstract class SobjectTableServiceAbstract {
	@TestVisible protected String sobjectName;
	@TestVisible protected List<String> selectFields;
	@TestVisible protected DynamicSOQLConditionBlock conditionBlock;
	@TestVisible protected DynamicSOQLOrderBy orderBy;
	@TestVisible protected Integer limitRecords;
	@TestVisible protected Integer offsetRecords;
	
	/**
	 * @description The IConstructable interface allows to enable reflection for the SobjectTableServiceAbstract
	 * and prevents using static methods for service instantiation.
	 * @param  inputJSON inputJSON the JSON string which represents the SobjectTableServiceAbstract
	 * @return           {SobjectTableServiceAbstract}
	 */
	public interface IConstructable {
		SobjectTableServiceAbstract construct(String inputJSON);
	}

	/**
	 * @description The method allows overriding the table data after it's been selected.
	 * @return   return {List<Object>}
	 */
	virtual public List<Object> tableRows() {
		return this.sobjectRecords();
	}

	/* ABSTRACT METHODS */

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
