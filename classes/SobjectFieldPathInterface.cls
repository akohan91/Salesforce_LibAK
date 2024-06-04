/**
 * @author Andrei Kakhanouski <akohan91@gmail.com>
 */
public interface SobjectFieldPathInterface {
	/**
	 * @description Returns field path. Example: Account.Name
	 * @return   { String }
	 */
	String path();

	/**
	 * @description Returns reference path for target sobject
	 * if sobject is 'Contact' and path is 'account.name' it returns 'account.id'
	 * @return   { String }
	 */
	String targetReferencePath();

	/**
	 * @description Returns DescribeFieldResult for a target field.
	 * @return   { DescribeFieldResult }
	 */
	Schema.DescribeFieldResult targetFieldDescribe();
}
