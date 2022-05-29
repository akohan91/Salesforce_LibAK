/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 * The class is used to manage custom APIs.
 *
 * To create a new endpoint you need to create new class with name in format: APIv001ClassName
 * and extend the AbstractRestProcessor.
 * The endpoint will look like this: https://instance.salesforce.com/services/apexrest/v001/ClassName
 *
 * Example:
 * public class APIv001DemoRestRouter extends AbstractRestProcessor
 * https://instance.salesforce.com/services/apexrest/v001/DemoRestRouter
 */
public with sharing abstract class AbstractRestProcessor {

	protected RestRequest request;

	/* ABSTRACT METHODS */
	private abstract ResponseInterface handleGet();
	private abstract ResponseInterface handlePost();
	private abstract ResponseInterface handlePut();
	private abstract ResponseInterface handlePatch();
	private abstract ResponseInterface handleDelete();

	/* FACTORY METHOD */
	public static AbstractRestProcessor getInstance(RestRequest request) {
		List<String> uri = request.requestURI.removeStartIgnoreCase('/').split('/');
		String processorName = 'API' +
			uri.remove(0) + // API version in format v001
			uri.remove(0);  // The rest of className
		request.requestURI = '/' + String.join(uri, '/');
		Type processorType = Type.forName(processorName);
		if (processorType == null) {
			throw new RestProcessorException(System.Label.NoRestProcessor + processorName);
		}

		AbstractRestProcessor processor = (AbstractRestProcessor) processorType.newInstance();
		if (processor == null) {
			throw new RestProcessorException(System.Label.NoRestProcessor + processorName);
		}
		processor.request = request;

		return processor;
	}

	/* PUBLIC METHODS */
	public ResponseInterface process() {
		ResponseInterface response;
		switch on(String) this.request.httpMethod {
			when 'GET' {
				response = handleGet();
			}
			when 'POST' {
				response = handlePost();
			}
			when 'PUT' {
				response = handlePut();
			}
			when 'PATCH' {
				response = handlePatch();
			}
			when 'DELETE' {
				response = handleDelete();
			}
		}
		return response;
	}

	public class RestProcessorException extends Exception {}
}