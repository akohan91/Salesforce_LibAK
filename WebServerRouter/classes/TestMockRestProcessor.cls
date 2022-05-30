@IsTest
public with sharing class TestMockRestProcessor extends AbstractRestProcessor {

	private ResponseInterface handleGet() {
		return new ResponseJSON('This is a response from GET http method.');
	}

	private ResponseInterface handlePost() {
		return (ResponseInterface)new ResponseJSON('This is a response from POST http method.')
		.setHttpStatusCode(200)
		.addHeader('key', 'value');
	}

	private ResponseInterface handlePut() {
		throw new RestProcessorException('The PUT http method is not available for this resource.');
	}

	private ResponseInterface handlePatch() {
		throw new RestProcessorException('The PATCH http method is not available for this resource.');
	}

	private ResponseInterface handleDelete() {
		return new ResponseJSON('This is a response from DELETE http method.');
	}
}
