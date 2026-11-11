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

  # Lifecycle / state verification scenarios (issue #87)

  @knowledge_base_create_02_create_then_get_lifecycle
  Scenario: Create then get - the created knowledge base is retrievable
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    When the request "getKnowledgeBase" is sent
    Then the response status code is 200
    And the response body complies with the OAS schema at "#/components/schemas/KnowledgeBase"
    And the response property "$.knowledgeBaseId" has the same value as the identifier of that knowledge base
    And the response property "$.name" has the same value as the name used when that knowledge base was created

  ############################ Error Scenarios #############################################

  # Syntax Error scenarios
  @knowledge_base_create_400_01_schema_not_compliant
  Scenario: Invalid Argument. Schema Violation
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

  # Common 403 error (PermissionDenied403)
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

  # Common mandatory error scenarios (issue #87)

  @knowledge_base_create_400_04_unknown_top_level_property
  Scenario: Request body strictness - undeclared property is rejected
    Given the request body is set by default to a request body compliant with the schema at "#/components/schemas/KnowledgeBaseCreateRequest"
    And the request body property "$.unknownProperty" is set to "value"
    When the request "createKnowledgeBase" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_create_400_05_invalid_x_correlator
  Scenario: Invalid x-correlator header value
    Given the request body is set by default to a request body compliant with the schema at "#/components/schemas/KnowledgeBaseCreateRequest"
    And the header "x-correlator" is set to "invalid correlator!"
    When the request "createKnowledgeBase" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_create_401_01_no_authorization_header
  Scenario: Error response for no header "Authorization"
    Given the request body is set by default to a request body compliant with the schema at "#/components/schemas/KnowledgeBaseCreateRequest"
    And the header "Authorization" is not sent
    When the request "createKnowledgeBase" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_create_401_02_no_access_token
  Scenario: Error response for no access token in the "Authorization" header
    Given the request body is set by default to a request body compliant with the schema at "#/components/schemas/KnowledgeBaseCreateRequest"
    And the header "Authorization" is set to "Bearer"
    When the request "createKnowledgeBase" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_create_401_03_expired_access_token
  Scenario: Error response for expired access token
    Given the request body is set by default to a request body compliant with the schema at "#/components/schemas/KnowledgeBaseCreateRequest"
    And the header "Authorization" is set to an expired access token
    When the request "createKnowledgeBase" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text
