Feature: CAMARA MaaS Q&A Assistant Service API, v0.2.0-rc.1

    CAMARA Commonalities: 0.8.0

    # Input to be provided by the implementation to the tester
    #
    # Implementation indications:
    # * apiRoot: API root of the server URL
    #
    # Testing assets:
    # * As a user, I want to query answers using a specified QA assistant and knowledge base.
    #
    # References to OAS spec schemas refer to schemas specified in qa-assistant-service.yaml

  Background: Common QA assistant service setup
    Given an environment at "apiRoot"
    And the resource "/qa-assistant-service/v0.2rc1/answer"
    And the header "Content-Type" is set to "application/json"
    And the header "Authorization" is set to a valid access token
    And the header "x-correlator" complies with the schema at "#/components/schemas/XCorrelator"

  ############################ Happy Path Scenarios #############################################

  @qa_assistant_service_query_01_success
  Scenario: Get a valid answer successfully
    And the request body is set by default to a request body compliant with the schema at "#/components/schemas/QueryRequest"
    When the request "queryAssistant" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/QueryResponse"

  @qa_assistant_service_query_02_stop
  Scenario: Response finished with Stop status
    And the request body is set by default to a request body compliant with the schema at "#/components/schemas/QueryRequest"
    When the request "queryAssistant" is sent
    Then the response status code is 200
    And the response property "$.finished" is "STOP"
    And the response property "$.success" is true

  @qa_assistant_service_query_03_length
  Scenario: Answer truncated due to token limit
    Given the assistant's response exceeds the token limit
    And the request body is compliant with the schema at "#/components/schemas/QueryRequest"
    When the request "queryAssistant" is sent
    Then the response status code is 200
    And the response property "$.finished" is "LENGTH"
    And the response property "$.success" is true

  @qa_assistant_service_query_04_filter
  Scenario: Content filter blocks answer
    Given the generated answer triggers content filter
    And the request body is compliant with the schema at "#/components/schemas/QueryRequest"
    When the request "queryAssistant" is sent
    Then the response status code is 200
    And the response property "$.finished" is "FILTER"
    And the response property "$.success" is false

  @qa_assistant_service_query_05_error
  Scenario: Response generation error
    Given the assistant encounters an internal error during processing
    And the request body is compliant with the schema at "#/components/schemas/QueryRequest"
    When the request "queryAssistant" is sent
    Then the response status code is 200
    And the response property "$.finished" is "ERROR"
    And the response property "$.success" is false

  ############################ Error Scenarios #############################################

  # Syntax Error scenarios

  @qa_assistant_service_query_400_01_schema_not_compliant
  Scenario: Invalid Argument. Generic Syntax Exception
    Given the request body is included but is not compliant with the schema at "#/components/schemas/QueryRequest"
    When the request "queryAssistant" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @qa_assistant_service_query_400_02_no_request_body
  Scenario: Missing request body
    Given the request body is not included
    When the request "queryAssistant" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @qa_assistant_service_query_400_03_empty_request_body
  Scenario: Empty object as request body
    Given the request body is set to {}
    When the request "queryAssistant" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @qa_assistant_service_query_400_04_missing_required_property
  Scenario: Error response for missing required property in request body
    Given the request body property "$.prompt" is not included
    When the request "queryAssistant" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @qa_assistant_service_query_400_05_out_of_range
  Scenario: Error response for prompt exceeding max length
    Given the request body property "$.prompt" exceeds the maximum allowed length
    When the request "queryAssistant" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "OUT_OF_RANGE"
    And the response property "$.message" contains a user friendly text

  # Authentication/Authorization errors

  @qa_assistant_service_query_401_01_no_authorization_header
  Scenario: Error response for no header "Authorization"
    Given the header "Authorization" is not sent
    When the request "queryAssistant" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @qa_assistant_service_query_401_02_expired_access_token
  Scenario: Error response for expired access token
    Given the header "Authorization" is set to an expired access token
    When the request "queryAssistant" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @qa_assistant_service_query_401_03_invalid_access_token
  Scenario: Error response for invalid access token
    Given the header "Authorization" is set to an invalid access token
    When the request "queryAssistant" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  # Generic 403 errors

  @qa_assistant_service_query_403_01_missing_scope
  Scenario: Missing access token scope
    Given the header "Authorization" is set to an access token that does not include scope "qa-assistant-service:answer:read"
    When the request "queryAssistant" is sent
    Then the response status code is 403
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  # Generic 404 Error

  @qa_assistant_service_query_404_01_not_found
  Scenario: Assistant not found
    Given the request body property "$.assistantId" is set to a non-existing assistant ID
    When the request "queryAssistant" is sent
    Then the response status code is 404
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text

  # Generic 500 Error

  @qa_assistant_service_query_500_01_internal_error
  Scenario: Internal server error
    Given the system is in a faulty state
    When the request "queryAssistant" is sent
    Then the response status code is 500
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 500
    And the response property "$.code" is "INTERNAL"
    And the response property "$.message" contains a user friendly text
