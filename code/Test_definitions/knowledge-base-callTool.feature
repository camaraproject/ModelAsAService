Feature: CAMARA MaaS Knowledge Base API, v0.2.0-rc.2 - Operation callTool

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
    And the resource "/knowledge-base/v0.2rc2/knowledge-bases"
    And the header "Content-Type" is set to "application/json"
    And the header "Authorization" is set to a valid access token
    And the header "x-correlator" complies with the schema at "#/components/schemas/XCorrelator"

  ############################ Happy Path Scenarios #############################################

  @knowledge_base_tool_call_01_success
  Scenario: Invoke a tool successfully
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool"
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/v0.2rc2/knowledge-bases/{knowledgeBaseId}/tools/{toolId}/call"
    And the request body is set by default to a request body compliant with the schema at "#/components/schemas/ToolCallRequest"
    When the request "callTool" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/ToolCallResponse"

  @knowledge_base_tool_call_02_upstream_failure
  Scenario: callTool reflects an upstream 5xx via success=false and contextCode
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool"
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/v0.2rc2/knowledge-bases/{knowledgeBaseId}/tools/{toolId}/call"
    And the upstream tool is configured to return HTTP 500
    And the request body is set by default to a request body compliant with the schema at "#/components/schemas/ToolCallRequest"
    When the request "callTool" is sent
    Then the response status code is 200
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/ToolCallResponse"
    And the response property "$.success" is false
    And the response property "$.statusCode" is 500
    And the response property "$.contextCode" is "KNOWLEDGE_BASE.TOOL_EXECUTION_FAILED"

  @knowledge_base_tool_call_03_upstream_rate_limited
  Scenario: callTool reports upstream rate-limit via 200 envelope
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool"
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/v0.2rc2/knowledge-bases/{knowledgeBaseId}/tools/{toolId}/call"
    And the upstream tool is configured to return HTTP 429
    And the request body is set by default to a request body compliant with the schema at "#/components/schemas/ToolCallRequest"
    When the request "callTool" is sent
    Then the response status code is 200
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.success" is false
    And the response property "$.statusCode" is 429
    And the response property "$.contextCode" is "KNOWLEDGE_BASE.TOOL_RATE_LIMITED"

  ############################ Error Scenarios #############################################

  # Generic 404 Errors
  @knowledge_base_tool_call_404_01_not_found
  Scenario: Invoke non-existing tool
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the path parameter "toolId" is set to a random UUID
    And the resource "/knowledge-base/v0.2rc2/knowledge-bases/{knowledgeBaseId}/tools/{toolId}/call"
    And the request body is set by default to a request body compliant with the schema at "#/components/schemas/ToolCallRequest"
    When the request "callTool" is sent
    Then the response status code is 404
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text

  # callTool business error scenarios
  @knowledge_base_tool_call_400_01_arguments_schema_mismatch
  Scenario: callTool arguments do not conform to the tool's inputSchema
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool" with inputSchema requiring "query" (string) and "maxResults" (integer)
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/v0.2rc2/knowledge-bases/{knowledgeBaseId}/tools/{toolId}/call"
    And the request body property "$.arguments.query" is set to an integer instead of a string
    When the request "callTool" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"

  @knowledge_base_tool_call_422_01_tool_disabled
  Scenario: callTool on a disabled tool returns 422 KNOWLEDGE_BASE.TOOL_DISABLED
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool" that is currently disabled
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/v0.2rc2/knowledge-bases/{knowledgeBaseId}/tools/{toolId}/call"
    And the request body is set by default to a request body compliant with the schema at "#/components/schemas/ToolCallRequest"
    When the request "callTool" is sent
    Then the response status code is 422
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 422
    And the response property "$.code" is "KNOWLEDGE_BASE.TOOL_DISABLED"

  @knowledge_base_tool_call_422_02_invalid_input
  Scenario: callTool returns 422 KNOWLEDGE_BASE.TOOL_INVALID_INPUT for semantic violation
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool"
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/v0.2rc2/knowledge-bases/{knowledgeBaseId}/tools/{toolId}/call"
    And the request body property "$.arguments" contains values that violate a business rule (e.g. negative maxResults)
    When the request "callTool" is sent
    Then the response status code is 422
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 422
    And the response property "$.code" is "KNOWLEDGE_BASE.TOOL_INVALID_INPUT"

  @knowledge_base_tool_call_403_01_missing_scope
  Scenario: callTool with missing scope
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing tool created by operation "createTool"
    And the path parameter "toolId" is set to the value of the identifier for that tool
    And the resource "/knowledge-base/v0.2rc2/knowledge-bases/{knowledgeBaseId}/tools/{toolId}/call"
    And the header "Authorization" is set to an access token that does not include scope "knowledge-base:tools:call"
    And the request body is set by default to a request body compliant with the schema at "#/components/schemas/ToolCallRequest"
    When the request "callTool" is sent
    Then the response status code is 403
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
