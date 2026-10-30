Feature: CAMARA MaaS Knowledge Base API, vwip - Operation updateTool

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

  ############################ Error Scenarios #############################################

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

  # Common 403 error (PermissionDenied403) for other tool operations
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
