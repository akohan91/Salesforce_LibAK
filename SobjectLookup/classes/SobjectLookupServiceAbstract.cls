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

	/**
	 * @description The IConstructable interface allows to enable reflection for the SobjectLookupServiceAbstract
	 * and prevents using static methods for service instantiation.
	 * @param  inputJSON inputJSON the JSON string which represents the SobjectLookupServiceAbstract
	 * @return           {SobjectLookupServiceAbstract}
	 */
	public interface IConstructable {
		SobjectLookupServiceAbstract construct(String inputJSON);
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
}
