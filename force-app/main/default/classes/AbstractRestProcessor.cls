/**
 * @author Andrew Kohanovskij <akohan91@gmail.com>
 */
public with sharing abstract class AbstractRestProcessor {

	private static final String NO_PROCESSOR_MSG = System.Label.NoRestProcessor;
	private RestRequest request;

	/* ABSTRACT METHODS */
	private abstract void handleGet();
	private abstract void handlePost();
	private abstract void handlePut();
	private abstract void handlePatch();
	private abstract void handleDelete();

	/* FACTORY METHOD */
	public static AbstractRestProcessor getInstance(RestRequest request) {
		String processorName = request.requestURI.toLowerCase().substringAfter('/').replaceAll('/', '');
		Type processorType   = Type.forName(processorName);
		if (processorType == null) {
			throw new RestProcessorException(NO_PROCESSOR_MSG + processorName);
		}

		AbstractRestProcessor processor = (AbstractRestProcessor) processorType.newInstance();
		if (processor == null) {
			throw new RestProcessorException(NO_PROCESSOR_MSG + processorName);
		}
		processor.request = request;

		return processor;
	}

	/* PUBLIC METHODS */
	public void process() {
		switch on(String) this.request.httpMethod {
			when 'GET' {
				handleGet();
			}
			when 'POST' {
				handlePost();
			}
			when 'PUT' {
				handlePut();
			}
			when 'PATCH' {
				handlePatch();
			}
			when 'DELETE' {
				handleDelete();
			}
		}
	}

	public class RestProcessorException extends Exception {}
}