/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
public with sharing abstract class AbstractRestProcessor {

	private RestRequest request;

	/* ABSTRACT METHODS */
	private abstract ResponseInterface handleGet();
	private abstract ResponseInterface handlePost();
	private abstract ResponseInterface handlePut();
	private abstract ResponseInterface handlePatch();
	private abstract ResponseInterface handleDelete();

	/* FACTORY METHOD */
	public static AbstractRestProcessor getInstance(RestRequest request) {
		String processorName = request.requestURI.toLowerCase().substringAfter('/').replaceAll('/', '');
		Type processorType   = Type.forName(processorName);
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