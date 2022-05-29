/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
public interface ResponseInterface {

	/**
	 * @description Send the REST response to the client
	 */
	void sendResponse();

	/**
	 * @description Set the HTTP status code
	 * @param  statusCode { Integer } HTTP status code
	 * @return            { ResponseInterface }
	 */
	ResponseInterface setHttpStatusCode(Integer statusCode);

	/**
	 * @description Adds header to the response
	 * @param  key   { String } - header key
	 * @param  value { String } - header value
	 * @return       { ResponseInterface }
	 */
	ResponseInterface addHeader (String key, String value);
}
