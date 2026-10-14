Feature: CAMARA MaaS Knowledge Base API, vwip - Operation createKnowledgeBase

    CAMARA Commonalities: 0.9.0

    # Input to be provided by the implementation to the tester
    #
    # Implementation indications:
    # * apiRoot: API root of the server URL
    #
    # Testing assets:
    # * As a user, I want to manage the knowledge base using RESTful APIs.
    #
    # References to OAS spec schemas refer to schemas specified in knowledge-base.yaml

  Background: Common knowledge-base setup
    Given an environment at "apiRoot"
    And the resource "/knowledge-base/vwip/knowledge-bases"
    And the header "Content-Type" is set to "application/json"
    And the header "Authorization" is set to a valid access token
    And the header "x-correlator" complies with the schema at "#/components/schemas/XCorrelator"

  ############################ Happy Path Scenarios #############################################

  @knowledge_base_create_01_success
  Scenario: Create a new knowledge base successfully
    And the request body is set by default to a request body compliant with the schema at "#/components/schemas/KnowledgeBaseCreateRequest"
    When the request "createKnowledgeBase" is sent
    Then the response status code is 201
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/KnowledgeBase"

  ############################ Error Scenarios #############################################

  # Syntax Error scenarios
  @knowledge_base_create_400_01_schema_not_compliant
  Scenario: Invalid Argument. Generic Syntax Exception
    Given the request body is included but is not compliant with the schema at "#/components/schemas/KnowledgeBaseCreateRequest"
    When the request "createKnowledgeBase" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_create_400_02_no_request_body
  Scenario: Missing request body
    Given the request body is not included
    When the request "createKnowledgeBase" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_create_400_03_missing_required_property
  Scenario: Error response for missing required property "name" in request body
    Given the request body property "$.name" is not included
    When the request "createKnowledgeBase" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  # Generic 403 errors
  @knowledge_base_create_403_01_missing_scope
  Scenario: Missing access token scope
    Given the header "Authorization" is set to an access token that does not include scope "knowledge-base:knowledge-bases:create"
    When the request "createKnowledgeBase" is sent
    Then the response status code is 403
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  # Generic 500 Error
  @knowledge_base_create_500_01_internal_error
  Scenario: Internal server error
    Given the system is in a faulty state
    When the request "createKnowledgeBase" is sent
    Then the response status code is 500
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 500
    And the response property "$.code" is "INTERNAL"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_create_409_01_duplicate_name
  Scenario: Create knowledge base with a name that already exists
    Given an existing knowledge base created by operation "createKnowledgeBase" with name "duplicate-kb"
    And the request body property "$.name" is set to "duplicate-kb"
    And the request body is compliant with the schema at "#/components/schemas/KnowledgeBaseCreateRequest"
    When the request "createKnowledgeBase" is sent
    Then the response status code is 409
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 409
    And the response property "$.code" is "ALREADY_EXISTS"
