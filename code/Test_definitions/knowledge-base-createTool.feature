Feature: CAMARA MaaS Knowledge Base API, v0.2.0 - Operation createTool

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
    And the resource "/knowledge-base/v0.2/knowledge-bases"
    And the header "Content-Type" is set to "application/json"
    And the header "Authorization" is set to a valid access token
    And the header "x-correlator" complies with the schema at "#/components/schemas/XCorrelator"

  ############################ Happy Path Scenarios #############################################

  @knowledge_base_tool_create_01_success
  Scenario: Create a new tool successfully
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools"
    And the request body is set by default to a request body compliant with the schema at "#/components/schemas/ToolCreateRequest"
    When the request "createTool" is sent
    Then the response status code is 201
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/Tool"

  @knowledge_base_tool_create_02_default_method
  Scenario: Create a tool without specifying method (defaults to POST)
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools"
    And the request body is set by default to a request body compliant with the schema at "#/components/schemas/ToolCreateRequest"
    And the request body property "$.method" is not included
    When the request "createTool" is sent
    Then the response status code is 201
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/Tool"
    And the response property "$.method" is "POST"

  @knowledge_base_tool_create_03_with_patch_method
  Scenario: Create a tool with the PATCH method
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools"
    And the request body property "$.method" is set to "PATCH"
    And the request body is compliant with the schema at "#/components/schemas/ToolCreateRequest"
    When the request "createTool" is sent
    Then the response status code is 201
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/Tool"
    And the response property "$.method" is "PATCH"

  @knowledge_base_tool_create_04_with_headers_and_schemas
  Scenario: Create a tool with custom headers, inputSchema and outputSchema
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools"
    And the request body property "$.headers" is set to a valid headers object
    And the request body property "$.inputSchema" is set to a valid JSON Schema document
    And the request body property "$.outputSchema" is set to a valid JSON Schema document
    And the request body is compliant with the schema at "#/components/schemas/ToolCreateRequest"
    When the request "createTool" is sent
    Then the response status code is 201
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/Tool"

  # Lifecycle / state verification scenarios (issue #87)

  @knowledge_base_tool_create_05_create_then_get_lifecycle
  Scenario: Create then get - the created tool is retrievable
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool"
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools/{toolId}"
    When the request "getTool" is sent
    Then the response status code is 200
    And the response body complies with the OAS schema at "#/components/schemas/Tool"
    And the response property "$.toolId" has the same value as the identifier of that tool

  ############################ Error Scenarios #############################################

  # Syntax Error scenarios
  @knowledge_base_tool_create_400_01_missing_name
  Scenario: Create tool with missing required property "name"
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools"
    And the request body property "$.name" is not included
    When the request "createTool" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  # Tool pagination error scenarios
  @knowledge_base_tool_create_400_02_missing_url
  Scenario: Create tool with missing required property "url"
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools"
    And the request body property "$.url" is not included
    When the request "createTool" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  # Authentication/Authorization errors
  @knowledge_base_tool_create_403_01_missing_scope
  Scenario: Create tool with missing access token scope
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools"
    And the header "Authorization" is set to an access token that does not include scope "knowledge-base:tools:create"
    When the request "createTool" is sent
    Then the response status code is 403
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  # Syntax / validation errors
  @knowledge_base_tool_create_400_01_invalid_method
  Scenario: Create tool with invalid HTTP method (not in enum)
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools"
    And the request body property "$.method" is set to "TRACE"
    And the request body is compliant with the schema at "#/components/schemas/ToolCreateRequest"
    When the request "createTool" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"

  @knowledge_base_tool_create_400_02_invalid_url
  Scenario: Create tool with malformed URL
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools"
    And the request body property "$.url" is set to "not-a-valid-uri"
    And the request body is compliant with the schema at "#/components/schemas/ToolCreateRequest"
    When the request "createTool" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"

  @knowledge_base_tool_create_400_03_reserved_header
  Scenario: Create tool with reserved header (e.g. Host)
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools"
    And the request body property "$.headers.Host" is set to "evil.example.com"
    And the request body is compliant with the schema at "#/components/schemas/ToolCreateRequest"
    When the request "createTool" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"

  @knowledge_base_tool_create_400_04_header_value_too_long
  Scenario: Create tool with header value exceeding maxLength
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools"
    And the request body property "$.headers.X-Long-Header" is set to a string of 4097 characters
    And the request body is compliant with the schema at "#/components/schemas/ToolCreateRequest"
    When the request "createTool" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"

  @knowledge_base_tool_create_415_01_unsupported_media_type
  Scenario: Unsupported media type for tool creation
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools"
    And the request "Content-Type" header is set to "application/xml"
    When the request "createTool" is sent
    Then the response status code is 415
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 415
    And the response property "$.code" is "UNSUPPORTED_MEDIA_TYPE"

  @knowledge_base_tool_create_409_01_duplicate_name
  Scenario: Create tool with a name that already exists in the same knowledge base
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools"
    And an existing tool created by operation "createTool" with name "weather-lookup"
    And the request body property "$.name" is set to "weather-lookup"
    And the request body is compliant with the schema at "#/components/schemas/ToolCreateRequest"
    When the request "createTool" is sent
    Then the response status code is 409
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 409
    And the response property "$.code" is "ALREADY_EXISTS"

  # Common mandatory error scenarios (issue #87)

  @knowledge_base_tool_create_400_09_unknown_top_level_property
  Scenario: Request body strictness - undeclared property is rejected
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools"
    And the request body is set by default to a request body compliant with the schema at "#/components/schemas/ToolCreateRequest"
    And the request body property "$.unknownProperty" is set to "value"
    When the request "createTool" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_tool_create_400_10_invalid_x_correlator
  Scenario: Invalid x-correlator header value
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools"
    And the request body is set by default to a request body compliant with the schema at "#/components/schemas/ToolCreateRequest"
    And the header "x-correlator" is set to "invalid correlator!"
    When the request "createTool" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_tool_create_401_01_no_authorization_header
  Scenario: Error response for no header "Authorization"
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools"
    And the request body is set by default to a request body compliant with the schema at "#/components/schemas/ToolCreateRequest"
    And the header "Authorization" is not sent
    When the request "createTool" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_tool_create_401_02_no_access_token
  Scenario: Error response for no access token in the "Authorization" header
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools"
    And the request body is set by default to a request body compliant with the schema at "#/components/schemas/ToolCreateRequest"
    And the header "Authorization" is set to "Bearer"
    When the request "createTool" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_tool_create_401_03_expired_access_token
  Scenario: Error response for expired access token
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools"
    And the request body is set by default to a request body compliant with the schema at "#/components/schemas/ToolCreateRequest"
    And the header "Authorization" is set to an expired access token
    When the request "createTool" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_tool_create_404_01_not_found
  Scenario: non-existing knowledgeBaseId
    Given the path parameter "knowledgeBaseId" is set to a random UUID
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools"
    And the request body is set by default to a request body compliant with the schema at "#/components/schemas/ToolCreateRequest"
    When the request "createTool" is sent
    Then the response status code is 404
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text
