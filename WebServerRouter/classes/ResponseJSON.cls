/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
public with sharing class ResponseJSON implements ResponseInterface {
	protected Integer httpStatusCode = 200;
	protected Map<String, String> headers = new Map<String, String>();
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
		this(System.Label.Status_Error, exc.getMessage(), null);
		this.setHttpStatusCode(500);
	}

	/* PUBLIC METHODS */

	/**
	 * @description Set the HTTP status code
	 * @param  statusCode { Integer } HTTP status code
	 * @return            { ResponseJSON }
	 */
	public ResponseJSON setHttpStatusCode(Integer statusCode) {
		this.httpStatusCode = statusCode;
		return this;
	}

	/**
	 * @description Adds header to the response
	 * @param  key   { String } - header key
	 * @param  value { String } - header value
	 * @return       { ResponseJSON }
	 */
	public ResponseJSON addHeader (String key, String value) {
		this.headers.put(key, value);
		return this;
	}

	/**
	 * @description Sends the response with the JSON body serializes from itself
	 * @param  statusCode { Integer } HTTP status code
	 * @param  headers    { Map<String, String> } HTTP headers
	 * @param  body       { Blob } Response body as Blob
	 */
	public void sendResponse() {
		if (this.headers != null && !this.headers.isEmpty()) {
			for (String key : this.headers.keySet()) {
				RestContext.response.addHeader(key, this.headers.get(key));
			}
		}
		RestContext.response.addHeader('Content-Type', 'application/json');
		RestContext.response.statusCode   = this.httpStatusCode;
		RestContext.response.responseBody = BLOB.valueOf(JSON.serialize(
			new Map<String, object>{
				'status'  => this.status,
				'message' => this.message,
				'data'    => this.data
			}
		));
	}
}
