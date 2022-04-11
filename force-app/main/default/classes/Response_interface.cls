/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
public interface Response_interface {

	/**
	 * @description Send the REST response to the client
	 * @param  statusCode { Integer } HTTP status code
	 * @param  headers    { Map<String, String> } HTTP headers
	 */
	void sendResponse(Integer statusCode, Map<String, String> headers);

	/**
	 * @description Sends the response with the status code 500 and message from Exception instance
	 */
	void sendServerErrorResponse();
}
