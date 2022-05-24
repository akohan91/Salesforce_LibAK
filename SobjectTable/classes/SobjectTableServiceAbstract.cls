/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
public abstract class SobjectTableServiceAbstract {
	@TestVisible
	protected String sobjectName;
	@TestVisible
	protected List<String> selectFields;
	@TestVisible
	protected DynamicSOQLConditionBlock conditionBlock;
	@TestVisible
	protected DynamicSOQLOrderBy orderBy;
	@TestVisible
	protected Integer limitRecords;
	@TestVisible
	protected Integer offsetRecords;

	/* ABSTRACT METHODS */

	abstract public List<SObject> sobjectRecords();
	abstract public Integer recordsCount();
	abstract public List<String> addressFieldPaths();
	abstract public List<String> referenceFieldPaths();
	abstract public List<Object> dataTableColumns();
}
