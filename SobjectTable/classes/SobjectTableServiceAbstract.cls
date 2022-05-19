/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
public abstract class SobjectTableServiceAbstract {
	protected String sobjectName;
	protected List<String> selectFields;
	protected DynamicSOQLConditionBlock conditionBlock;
	protected Integer limitRecords;
	protected Integer offsetRecords;

	abstract public List<SObject> sobjectRecords();
	abstract public Integer recordsCount();
	abstract public List<String> addressFieldPaths();
	abstract public List<String> referenceFieldPaths();
	abstract public List<Object> dataTableColumns();
}
