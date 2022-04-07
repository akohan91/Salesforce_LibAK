/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
public with sharing class ResponseJSON implements Response_interface {
	protected String status;
	protected String message;
	protected Object data;

	/* CONSTRUCTORS */

	/**
	 * @description Constracts a new ResponseJSON object
	 * @param  status  { String } Could be 'Success' | 'Error'
	 * @param  message { String }
	 * @param  data    { Object }
	 */
	public ResponseJSON(String status, String message, Object data) {
		this.status  = status;
		this.message = message;
		this.data    = data;
	}

	/**
	 * @description Constracts a new ResponseJSON object with a default status 'Success' and empty message
	 * @param  data { Object }
	 */
	public ResponseJSON(Object data) {
		this(System.Label.Status_Success, null, data);
	}

	/**
	 * @description Constracts a new ResponseJSON object with a default status 'Error', message from Exception instance and null data
	 * @param  exc { Exception }
	 */
	public ResponseJSON(Exception exc) {
		this(System.Label.Status_Error, exc.getTypeName() + ' : ' + exc.getMessage(), null);
	}

	/* PUBLIC METHODS */

	/**
	 * @description Sends the response with the JSON body serializes from itself
	 * @param  statusCode { Integer } HTTP status code
	 * @param  headers    { Map<String, String> } HTTP headers
	 * @param  body       { Blob } Response body as Blob
	 */
	public void sendResponse(Integer statusCode, Map<String, String> headers) {

		if (headers != null && !headers.isEmpty()) {
			for (String key : headers.keySet()) {
				RestContext.response.addHeader(key, headers.get(key));
			}
		}
		RestContext.response.addHeader('Content-Type', 'application/json');
		RestContext.response.statusCode   = statusCode;
		RestContext.response.responseBody = BLOB.valueOf(JSON.serialize(this));
	}

	/**
	 * @description Sends the response with the status code 500 and message from Exception instance
	 */
	public void sendServerErrorResponse() {
		this.sendResponse(500, new Map<String, String>());
	}
}
