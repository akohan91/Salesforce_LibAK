/**
* @author Andrew Kohanovskij <akohan91@gmail.com>
 */
public with sharing class Response {
	protected String status;
	protected String message;
	protected Object data;

	/* CONSTRUCTORS */

	/**
	 * @description Constracts a new Response object
	 * @param  status  { String } Could be 'Success' | 'Error'
	 * @param  message { String }
	 * @param  data    { Object }
	 */
	public Response(String status, String message, Object data) {
		this.status  = status;
		this.message = message;
		this.data    = data;
	}

	/**
	 * @description Constracts a new Response object with a default status 'Success' and empty message
	 * @param  data { Object }
	 */
	public Response(Object data) {
		this(System.Label.Status_Success, null, data);
	}

	/**
	 * @description Constracts a new Response object with a default status 'Error', message from Exception instance and null data
	 * @param  exc { Exception }
	 */
	public Response(Exception exc) {
		this(System.Label.Status_Error, exc.getTypeName() + ' : ' + exc.getMessage(), null);
	}

	/* PUBLIC METHODS */


	/**
	 * @description Makes the JSON string from itself
	 * @return   return { String } string in JSON format
	 */
	public String json() {
		return JSON.serialize(this);
	}

	/**
	 * @description Sends the response with the JSON body serializes from itself
	 * @param  statusCode { Integer } HTTP status code
	 * @param  headers    { Map<String, String> } HTTP headers
	 * @param  body       { Blob } Response body as Blob
	 */
	public void sendResponse(Integer statusCode, Map<String, String> headers, Blob body) {
		for (String key : headers.keySet()) {
			RestContext.response.addHeader(key, headers.get(key));
		}
		RestContext.response.statusCode   = statusCode;
		RestContext.response.responseBody = body;
	}

	/**
	 * @description Sends the response with the JSON body serializes from itself
	 * @param  statusCode { Integer } HTTP status code
	 * @param  headers    { Map<String, String> } HTTP headers
	 */
	public void sendJsonResponse(Integer statusCode, Map<String, String> headers) {
		if (headers == null) {
			headers = new Map<String,String>();
			headers.put('Content-Type', 'application/json');
		} else if (headers.get('Content-Type') != 'application/json') {
			headers.put('Content-Type', 'application/json');
		}
		this.sendResponse(
			statusCode,
			headers,
			Blob.valueOf(this.json())
		);
	}

	/**
	 * @description Sends the response with the status code 500 and message from Exception instance
	 */
	public void sendServerErrorResponse() {
		this.sendJsonResponse(500, null);
	}
}
