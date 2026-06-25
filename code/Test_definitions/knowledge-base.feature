Feature: CAMARA MaaS Knowledge Base API, vwip

    CAMARA Commonalities: 0.8.0

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

  @knowledge_base_list_01_success
  Scenario: Get all knowledge bases successfully
    Given at least an existing knowledge base created by operation "createKnowledgeBase"
    When the request "listKnowledgeBases" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.items" is an array whose items comply with the OAS schema at "#/components/schemas/KnowledgeBase"
    And the response property "$.pagination" complies with the OAS schema at "../common/CAMARA_common.yaml#/components/schemas/Pagination"

  @knowledge_base_list_02_empty
  Scenario: No existing knowledge bases
    Given no knowledge bases have been created by operation "createKnowledgeBase"
    When the request "listKnowledgeBases" is sent
    Then the response status code is 200
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.items" is an empty array "[]"
    And the response property "$.pagination" complies with the OAS schema at "../common/CAMARA_common.yaml#/components/schemas/Pagination"

  @knowledge_base_get_01_success
  Scenario: Get a specific knowledge base by ID
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    When the request "getKnowledgeBase" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/KnowledgeBase"

  @knowledge_base_update_01_success
  Scenario: Update an existing knowledge base
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the request body is compliant with the schema at "#/components/schemas/KnowledgeBaseUpdateRequest"
    When the request "updateKnowledgeBase" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/KnowledgeBase"

  @knowledge_base_delete_01_success
  Scenario: Delete a knowledge base successfully
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    When the request "deleteKnowledgeBase" is sent
    Then the response status code is 204
    And the response header "x-correlator" has the same value as the request header "x-correlator"

  @knowledge_base_upload_document_01_success
  Scenario: Upload valid document to knowledge base
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And a valid document file with format pdf is available
    When the request "uploadDocument" is sent
    Then the response status code is 201
    And the response header "x-correlator" has the same value as the request header "x-correlator"

  ############################ Tool Happy Path Scenarios #############################################

  @knowledge_base_tool_create_01_success
  Scenario: Create a new tool successfully
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools"
    And the request body is set by default to a request body compliant with the schema at "#/components/schemas/ToolCreateRequest"
    When the request "createTool" is sent
    Then the response status code is 201
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/Tool"

  @knowledge_base_tool_list_01_success
  Scenario: List tools successfully
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools"
    Given at least an existing tool created by operation "createTool"
    When the request "listTools" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.items" is an array whose items comply with the OAS schema at "#/components/schemas/Tool"
    And the response property "$.pagination" complies with the OAS schema at "../common/CAMARA_common.yaml#/components/schemas/Pagination"

  @knowledge_base_tool_get_01_success
  Scenario: Get a specific tool by ID
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool"
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools/{toolId}"
    When the request "getTool" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/Tool"

  @knowledge_base_tool_update_01_success
  Scenario: Update an existing tool
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool"
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools/{toolId}"
    And the request body is compliant with the schema at "#/components/schemas/ToolUpdateRequest"
    When the request "updateTool" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/Tool"

  @knowledge_base_tool_delete_01_success
  Scenario: Delete a tool successfully
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool"
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools/{toolId}"
    When the request "deleteTool" is sent
    Then the response status code is 204
    And the response header "x-correlator" has the same value as the request header "x-correlator"

  @knowledge_base_tool_call_01_success
  Scenario: Invoke a tool successfully
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool"
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools/{toolId}/call"
    And the request body is set by default to a request body compliant with the schema at "#/components/schemas/ToolCallRequest"
    When the request "callTool" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/ToolCallResponse"

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

  @knowledge_base_create_400_03_empty_request_body
  Scenario: Empty object as request body
    Given the request body is set to {}
    When the request "createKnowledgeBase" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_create_400_04_missing_required_property
  Scenario: Error response for missing required property "name" in request body
    Given the request body property "$.name" is not included
    When the request "createKnowledgeBase" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_create_400_05_invalid_x-correlator
  Scenario: Invalid x-correlator header
    Given the header "x-correlator" does not comply with the schema at "#/components/schemas/XCorrelator"
    When the request "createKnowledgeBase" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"

  # Pagination error scenarios

  @knowledge_base_list_400_01_page_negative
  Scenario: Invalid negative page parameter
    Given the query parameter "page" is set to -1
    When the request "listKnowledgeBases" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"

  @knowledge_base_list_400_02_perPage_exceeds_max
  Scenario: PerPage exceeds maximum allowed value
    Given the query parameter "perPage" is set to 999
    When the request "listKnowledgeBases" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "OUT_OF_RANGE"

  @knowledge_base_upload_document_400_01_invalid_format
  Scenario: Upload document with unsupported format
    Given the request body contains an unsupported document format
    When the request "uploadDocument" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  # Authentication/Authorization errors

  @knowledge_base_401_01_no_authorization_header
  Scenario: Error response for no header "Authorization"
    Given the header "Authorization" is not sent
    When the request "listKnowledgeBases" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_401_02_expired_access_token
  Scenario: Error response for expired access token
    Given the header "Authorization" is set to an expired access token
    When the request "listKnowledgeBases" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_401_03_invalid_access_token
  Scenario: Error response for invalid access token
    Given the header "Authorization" is set to an invalid access token
    When the request "listKnowledgeBases" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
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

  # Generic 404 Errors

  @knowledge_base_get_404_01_not_found
  Scenario: non-existing knowledgeBaseId
    Given the path parameter "knowledgeBaseId" is set to a random UUID
    When the request "getKnowledgeBase" is sent
    Then the response status code is 404
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_update_404_01_not_found
  Scenario: Update non-existing knowledgeBaseId
    Given the path parameter "knowledgeBaseId" is set to a random UUID
    Given the request body is compliant with the schema at "#/components/schemas/KnowledgeBaseUpdateRequest"
    When the request "updateKnowledgeBase" is sent
    Then the response status code is 404
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"

  @knowledge_base_delete_404_01_not_found
  Scenario: Delete non-existing knowledgeBaseId
    Given the path parameter "knowledgeBaseId" is set to a random UUID
    When the request "deleteKnowledgeBase" is sent
    Then the response status code is 404
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"

  # Generic 415 Error

  @knowledge_base_upload_document_415_01_unsupported_media_type
  Scenario: Unsupported media type for document upload
    Given the request has a payload format in an unsupported format
    When the request "uploadDocument" is sent
    Then the response status code is 415
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 415
    And the response property "$.code" is "UNSUPPORTED_MEDIA_TYPE"
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

  ############################ Tool Error Scenarios #############################################

  # Syntax Error scenarios

  @knowledge_base_tool_create_400_01_missing_name
  Scenario: Create tool with missing required property "name"
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools"
    Given the request body property "$.name" is not included
    When the request "createTool" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  # Tool pagination error scenarios

  @knowledge_base_tool_list_400_01_page_negative
  Scenario: Invalid negative page parameter for tool list
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools"
    Given the query parameter "page" is set to -1
    When the request "listTools" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"

  @knowledge_base_tool_list_400_02_perPage_exceeds_max
  Scenario: PerPage exceeds maximum allowed value for tool list
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools"
    Given the query parameter "perPage" is set to 999
    When the request "listTools" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "OUT_OF_RANGE"

  @knowledge_base_tool_create_400_02_missing_url
  Scenario: Create tool with missing required property "url"
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools"
    Given the request body property "$.url" is not included
    When the request "createTool" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  # Authentication/Authorization errors

  @knowledge_base_tool_401_01_no_authorization_header
  Scenario: Tool operation with no Authorization header
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools"
    Given the header "Authorization" is not sent
    When the request "listTools" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_tool_create_403_01_missing_scope
  Scenario: Create tool with missing access token scope
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools"
    Given the header "Authorization" is set to an access token that does not include scope "knowledge-base:tools:create"
    When the request "createTool" is sent
    Then the response status code is 403
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  # Generic 404 Errors

  @knowledge_base_tool_get_404_01_not_found
  Scenario: Get non-existing tool
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the path parameter "toolId" is set to a random UUID
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools/{toolId}"
    When the request "getTool" is sent
    Then the response status code is 404
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_tool_call_404_01_not_found
  Scenario: Invoke non-existing tool
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the path parameter "toolId" is set to a random UUID
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools/{toolId}/call"
    And the request body is set by default to a request body compliant with the schema at "#/components/schemas/ToolCallRequest"
    When the request "callTool" is sent
    Then the response status code is 404
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text

  # Generic 500 Error

  @knowledge_base_tool_create_500_01_internal_error
  Scenario: Internal server error during tool creation
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools"
    Given the system is in a faulty state
    When the request "createTool" is sent
    Then the response status code is 500
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 500
    And the response property "$.code" is "INTERNAL"
    And the response property "$.message" contains a user friendly text

  ############################ Additional Tool Happy Path Scenarios #############################################

  @knowledge_base_tool_list_02_empty
  Scenario: No existing tools in a knowledge base
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools"
    And no tools have been created by operation "createTool"
    When the request "listTools" is sent
    Then the response status code is 200
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.items" is an empty array "[]"
    And the response property "$.pagination" complies with the OAS schema at "../common/CAMARA_common.yaml#/components/schemas/Pagination"

  @knowledge_base_tool_create_02_default_method
  Scenario: Create a tool without specifying method (defaults to POST)
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools"
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
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools"
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
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools"
    And the request body property "$.headers" is set to a valid headers object
    And the request body property "$.inputSchema" is set to a valid JSON Schema document
    And the request body property "$.outputSchema" is set to a valid JSON Schema document
    And the request body is compliant with the schema at "#/components/schemas/ToolCreateRequest"
    When the request "createTool" is sent
    Then the response status code is 201
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/Tool"

  @knowledge_base_tool_call_02_upstream_failure
  Scenario: callTool reflects an upstream 5xx via success=false and contextCode
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool"
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools/{toolId}/call"
    And the upstream tool is configured to return HTTP 500
    And the request body is set by default to a request body compliant with the schema at "#/components/schemas/ToolCallRequest"
    When the request "callTool" is sent
    Then the response status code is 200
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/ToolCallResponse"
    And the response property "$.success" is false
    And the response property "$.statusCode" is 500
    And the response property "$.contextCode" is "TOOL.EXECUTION_FAILED"

  ############################ Additional Tool Error Scenarios #############################################

  # Syntax / validation errors

  @knowledge_base_tool_create_400_03_invalid_method
  Scenario: Create tool with invalid HTTP method (not in enum)
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools"
    And the request body property "$.method" is set to "TRACE"
    And the request body is compliant with the schema at "#/components/schemas/ToolCreateRequest"
    When the request "createTool" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"

  @knowledge_base_tool_create_400_04_invalid_url
  Scenario: Create tool with malformed URL
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools"
    And the request body property "$.url" is set to "not-a-valid-uri"
    And the request body is compliant with the schema at "#/components/schemas/ToolCreateRequest"
    When the request "createTool" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"

  @knowledge_base_tool_create_400_05_name_too_long
  Scenario: Create tool with name exceeding maxLength
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools"
    And the request body property "$.name" is set to a string of 256 characters
    And the request body is compliant with the schema at "#/components/schemas/ToolCreateRequest"
    When the request "createTool" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "OUT_OF_RANGE"

  @knowledge_base_tool_create_400_06_reserved_header
  Scenario: Create tool with reserved header (e.g. Host)
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools"
    And the request body property "$.headers.Host" is set to "evil.example.com"
    And the request body is compliant with the schema at "#/components/schemas/ToolCreateRequest"
    When the request "createTool" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"

  @knowledge_base_tool_create_400_07_too_many_headers
  Scenario: Create tool with more than 50 custom headers
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools"
    And the request body property "$.headers" is set to an object with 51 entries
    And the request body is compliant with the schema at "#/components/schemas/ToolCreateRequest"
    When the request "createTool" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "OUT_OF_RANGE"

  @knowledge_base_tool_create_400_08_header_value_too_long
  Scenario: Create tool with header value exceeding maxLength
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools"
    And the request body property "$.headers.X-Long-Header" is set to a string of 4097 characters
    And the request body is compliant with the schema at "#/components/schemas/ToolCreateRequest"
    When the request "createTool" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "OUT_OF_RANGE"

  @knowledge_base_tool_update_400_01_empty_body
  Scenario: Update tool with empty body (at least one field required)
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool"
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools/{toolId}"
    And the request body is set to {}
    When the request "updateTool" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"

  @knowledge_base_tool_create_415_01_unsupported_media_type
  Scenario: Unsupported media type for tool creation
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools"
    And the request "Content-Type" header is set to "application/xml"
    When the request "createTool" is sent
    Then the response status code is 415
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 415
    And the response property "$.code" is "UNSUPPORTED_MEDIA_TYPE"

  # callTool business error scenarios

  @knowledge_base_tool_call_400_01_arguments_schema_mismatch
  Scenario: callTool arguments do not conform to the tool's inputSchema
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool" with inputSchema requiring "query" (string) and "maxResults" (integer)
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools/{toolId}/call"
    And the request body property "$.arguments.query" is set to an integer instead of a string
    When the request "callTool" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"

  @knowledge_base_tool_call_422_01_tool_disabled
  Scenario: callTool on a disabled tool returns 422 TOOL.DISABLED
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool" that is currently disabled
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools/{toolId}/call"
    And the request body is set by default to a request body compliant with the schema at "#/components/schemas/ToolCallRequest"
    When the request "callTool" is sent
    Then the response status code is 422
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 422
    And the response property "$.code" is "TOOL.DISABLED"

  @knowledge_base_tool_call_422_02_invalid_input
  Scenario: callTool returns 422 TOOL.INVALID_INPUT for semantic violation
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool"
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools/{toolId}/call"
    And the request body property "$.arguments" contains values that violate a business rule (e.g. negative maxResults)
    When the request "callTool" is sent
    Then the response status code is 422
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 422
    And the response property "$.code" is "TOOL.INVALID_INPUT"

  @knowledge_base_tool_call_429_01_upstream_rate_limited
  Scenario: callTool returns 429 when upstream tool rate-limits
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool"
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools/{toolId}/call"
    And the upstream tool is configured to return HTTP 429
    And the request body is set by default to a request body compliant with the schema at "#/components/schemas/ToolCallRequest"
    When the request "callTool" is sent
    Then the response status code is 200
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.success" is false
    And the response property "$.statusCode" is 429
    And the response property "$.contextCode" is "TOOL.RATE_LIMITED"

  # Concurrent / state errors

  @knowledge_base_tool_update_409_01_concurrent_modification
  Scenario: Update tool returns 409 when the resource is being modified concurrently
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool"
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools/{toolId}"
    And the resource is being modified by another concurrent operation
    And the request body is compliant with the schema at "#/components/schemas/ToolUpdateRequest"
    When the request "updateTool" is sent
    Then the response status code is 409
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 409
    And the response property "$.code" is "ABORTED"

  @knowledge_base_tool_create_409_01_duplicate_name
  Scenario: Create tool with a name that already exists in the same knowledge base
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools"
    And an existing tool created by operation "createTool" with name "weather-lookup"
    And the request body property "$.name" is set to "weather-lookup"
    And the request body is compliant with the schema at "#/components/schemas/ToolCreateRequest"
    When the request "createTool" is sent
    Then the response status code is 409
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 409
    And the response property "$.code" is "ALREADY_EXISTS"

  # Other 404s

  @knowledge_base_tool_update_404_01_not_found
  Scenario: Update non-existing toolId
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the path parameter "toolId" is set to a random UUID
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools/{toolId}"
    And the request body is compliant with the schema at "#/components/schemas/ToolUpdateRequest"
    When the request "updateTool" is sent
    Then the response status code is 404
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"

  @knowledge_base_tool_delete_404_01_not_found
  Scenario: Delete non-existing toolId
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the path parameter "toolId" is set to a random UUID
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools/{toolId}"
    When the request "deleteTool" is sent
    Then the response status code is 404
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"

  # Generic 403s for other tool operations

  @knowledge_base_tool_update_403_01_missing_scope
  Scenario: Update tool with missing scope
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool"
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools/{toolId}"
    And the header "Authorization" is set to an access token that does not include scope "knowledge-base:tools:update"
    And the request body is compliant with the schema at "#/components/schemas/ToolUpdateRequest"
    When the request "updateTool" is sent
    Then the response status code is 403
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"

  @knowledge_base_tool_delete_403_01_missing_scope
  Scenario: Delete tool with missing scope
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool"
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools/{toolId}"
    And the header "Authorization" is set to an access token that does not include scope "knowledge-base:tools:delete"
    When the request "deleteTool" is sent
    Then the response status code is 403
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"

  @knowledge_base_tool_call_403_01_missing_scope
  Scenario: callTool with missing scope
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool"
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools/{toolId}/call"
    And the header "Authorization" is set to an access token that does not include scope "knowledge-base:tools:call"
    And the request body is set by default to a request body compliant with the schema at "#/components/schemas/ToolCallRequest"
    When the request "callTool" is sent
    Then the response status code is 403
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
