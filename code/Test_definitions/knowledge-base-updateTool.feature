Feature: CAMARA MaaS Knowledge Base API, v0.2.0 - Operation updateTool

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

  @knowledge_base_tool_update_01_success
  Scenario: Update an existing tool
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool"
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools/{toolId}"
    And the request body is compliant with the schema at "#/components/schemas/ToolUpdateRequest"
    When the request "updateTool" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/Tool"

  # Lifecycle / state verification scenarios (issue #87)

  @knowledge_base_tool_update_02_patch_semantics
  Scenario Outline: PATCH semantics - provided field is replaced, omitted field is left unchanged
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool" with name "original-tool-name" and description "original-tool-description"
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools/{toolId}"
    And the request body property "$.<updated_field>" is set to "<new_value>"
    And the request body is compliant with the schema at "#/components/schemas/ToolUpdateRequest"
    When the request "updateTool" is sent
    Then the response status code is 200
    And the response body complies with the OAS schema at "#/components/schemas/Tool"
    And the response property "$.<updated_field>" is "<new_value>"
    And the response property "$.<preserved_field>" has the same value as before the update
    Examples:
      | updated_field | new_value                 | preserved_field |
      | name          | patched-tool-name         | description     |
      | description   | patched-tool-description  | name            |

  @knowledge_base_tool_update_03_update_then_get_lifecycle
  Scenario: Update then get - the updated tool value is persisted
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool"
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools/{toolId}"
    And that tool has been updated by operation "updateTool" with name "lifecycle-updated-tool"
    When the request "getTool" is sent
    Then the response status code is 200
    And the response body complies with the OAS schema at "#/components/schemas/Tool"
    And the response property "$.name" is "lifecycle-updated-tool"

  ############################ Error Scenarios #############################################

  @knowledge_base_tool_update_400_01_empty_body
  Scenario: Update tool with empty body (at least one field required)
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool"
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools/{toolId}"
    And the request body is set to {}
    When the request "updateTool" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"

  # Concurrent / state errors
  @knowledge_base_tool_update_409_01_concurrent_modification
  Scenario: Update tool returns 409 when the resource is being modified concurrently
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool"
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools/{toolId}"
    And the resource is being modified by another concurrent operation
    And the request body is compliant with the schema at "#/components/schemas/ToolUpdateRequest"
    When the request "updateTool" is sent
    Then the response status code is 409
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 409
    And the response property "$.code" is "ABORTED"

  # Common 403 error (PermissionDenied403) for other tool operations
  @knowledge_base_tool_update_403_01_missing_scope
  Scenario: Update tool with missing scope
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool"
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools/{toolId}"
    And the header "Authorization" is set to an access token that does not include scope "knowledge-base:tools:update"
    And the request body is compliant with the schema at "#/components/schemas/ToolUpdateRequest"
    When the request "updateTool" is sent
    Then the response status code is 403
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"

  # Common mandatory error scenarios (issue #87)

  @knowledge_base_tool_update_400_02_no_request_body
  Scenario: Missing request body on update
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool"
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools/{toolId}"
    And the request body is not included
    When the request "updateTool" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_tool_update_400_03_unknown_top_level_property
  Scenario: Request body strictness - undeclared property is rejected
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool"
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools/{toolId}"
    And the request body is compliant with the schema at "#/components/schemas/ToolUpdateRequest"
    And the request body property "$.unknownProperty" is set to "value"
    When the request "updateTool" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_tool_update_400_04_invalid_x_correlator
  Scenario: Invalid x-correlator header value
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool"
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools/{toolId}"
    And the request body is compliant with the schema at "#/components/schemas/ToolUpdateRequest"
    And the header "x-correlator" is set to "invalid correlator!"
    When the request "updateTool" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_tool_update_400_05_malformed_tool_id
  Scenario: Invalid Argument. Malformed toolId (not a UUID)
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the path parameter "toolId" is set to "not-a-uuid"
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools/{toolId}"
    And the request body is compliant with the schema at "#/components/schemas/ToolUpdateRequest"
    When the request "updateTool" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_tool_update_401_01_no_authorization_header
  Scenario: Error response for no header "Authorization"
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool"
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools/{toolId}"
    And the request body is compliant with the schema at "#/components/schemas/ToolUpdateRequest"
    And the header "Authorization" is not sent
    When the request "updateTool" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_tool_update_401_02_no_access_token
  Scenario: Error response for no access token in the "Authorization" header
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool"
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools/{toolId}"
    And the request body is compliant with the schema at "#/components/schemas/ToolUpdateRequest"
    And the header "Authorization" is set to "Bearer"
    When the request "updateTool" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_tool_update_401_03_expired_access_token
  Scenario: Error response for expired access token
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool"
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools/{toolId}"
    And the request body is compliant with the schema at "#/components/schemas/ToolUpdateRequest"
    And the header "Authorization" is set to an expired access token
    When the request "updateTool" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_tool_update_404_01_not_found
  Scenario: non-existing toolId
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the path parameter "toolId" is set to a random UUID
    And the resource "/knowledge-base/v0.2/knowledge-bases/{knowledgeBaseId}/tools/{toolId}"
    And the request body is compliant with the schema at "#/components/schemas/ToolUpdateRequest"
    When the request "updateTool" is sent
    Then the response status code is 404
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text
