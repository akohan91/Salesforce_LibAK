/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
public interface SobjectFieldPathInterface {
	String path();
	String targetReferencePath();
	Schema.DescribeFieldResult targetFieldDescribe();
}
