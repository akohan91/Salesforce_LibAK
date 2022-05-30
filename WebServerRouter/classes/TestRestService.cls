@IsTest
public with sharing class TestRestService {
	@IsTest
	static void testGet(){
		Test.startTest();
		RestContext.response = new RestResponse();

		RestRequest request = new RestRequest();
        request.requestUri = '/TestMockRestProcessor';
        request.httpMethod = 'GET';
		RestContext.request = request;
		RestService.handleGet();

		Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
		System.assertEquals(
			'This is a response from GET http method.', (String)result.get('data'),
			'The data field of response JSON is wrong.'
		);
		System.assertEquals(
			null, (String)result.get('message'),
			'The message field of response JSON is wrong.'
		);
		System.assertEquals(
			System.Label.Status_Success, (String)result.get('status'),
			'The status field of response JSON is wrong.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testPost(){
		Test.startTest();
		RestContext.response = new RestResponse();

		RestRequest request = new RestRequest();
        request.requestUri = '/TestMockRestProcessor';
        request.httpMethod = 'POST';
		RestContext.request = request;
		RestService.handlePost();

		Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
		System.assertEquals(
			'This is a response from POST http method.', (String)result.get('data'),
			'The data field of response JSON is wrong.'
		);
		System.assertEquals(
			null, result.get('message'),
			'The message field of response JSON is wrong.'
		);
		System.assertEquals(
			System.Label.Status_Success, (String)result.get('status'),
			'The status field of response JSON is wrong.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testPut(){
		Test.startTest();
		RestContext.response = new RestResponse();

		RestRequest request = new RestRequest();
        request.requestUri = '/TestMockRestProcessor';
        request.httpMethod = 'PUT';
		RestContext.request = request;
		RestService.handlePut();

		Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
		System.assertEquals(
			null, (String)result.get('data'),
			'The data field of response JSON is wrong.'
		);
		System.assertEquals(
			'The PUT http method is not available for this resource.', result.get('message'),
			'The message field of response JSON is wrong.'
		);
		System.assertEquals(
			System.Label.Status_Error, (String)result.get('status'),
			'The status field of response JSON is wrong.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testPatch(){
		Test.startTest();
		RestContext.response = new RestResponse();

		RestRequest request = new RestRequest();
        request.requestUri = '/TestMockRestProcessor';
        request.httpMethod = 'PATCH';
		RestContext.request = request;
		RestService.handlePatch();

		Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
		System.assertEquals(
			null, (String)result.get('data'),
			'The data field of response JSON is wrong.'
		);
		System.assertEquals(
			'The PATCH http method is not available for this resource.', result.get('message'),
			'The message field of response JSON is wrong.'
		);
		System.assertEquals(
			System.Label.Status_Error, (String)result.get('status'),
			'The status field of response JSON is wrong.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testDelete(){
		Test.startTest();
		RestContext.response = new RestResponse();

		RestRequest request = new RestRequest();
        request.requestUri = '/TestMockRestProcessor';
        request.httpMethod = 'DELETE';
		RestContext.request = request;
		RestService.handleDelete();

		Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
		System.assertEquals(
			'This is a response from DELETE http method.', (String)result.get('data'),
			'The data field of response JSON is wrong.'
		);
		System.assertEquals(
			null, result.get('message'),
			'The message field of response JSON is wrong.'
		);
		System.assertEquals(
			System.Label.Status_Success, (String)result.get('status'),
			'The status field of response JSON is wrong.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testNoRestProcessor(){
		Test.startTest();
		RestContext.response = new RestResponse();

		RestRequest request = new RestRequest();
        request.requestUri = '/NoRestProcessor';
        request.httpMethod = 'GET';
		RestContext.request = request;
		RestService.handleGet();

		Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
		System.assertEquals(
			null, (String)result.get('data'),
			'The data field of response JSON is wrong.'
		);
		System.assertEquals(
			System.Label.NoRestProcessor + 'NoRestProcessor', result.get('message'),
			'The message field of response JSON is wrong.'
		);
		System.assertEquals(
			System.Label.Status_Error, (String)result.get('status'),
			'The status field of response JSON is wrong.'
		);
		Test.stopTest();
	}
}
