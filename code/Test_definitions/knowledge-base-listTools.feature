Feature: CAMARA MaaS Knowledge Base API, vwip - Operation listTools

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

  @knowledge_base_tool_list_01_success
  Scenario: List tools successfully
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools"
    And at least an existing tool created by operation "createTool"
    When the request "listTools" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.items" is an array whose items comply with the OAS schema at "#/components/schemas/Tool"
    And the response property "$.pagination" complies with the OAS schema at "#/components/schemas/Pagination"

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
    And the response property "$.pagination" complies with the OAS schema at "#/components/schemas/Pagination"

  ############################ Error Scenarios #############################################

  # Common mandatory error scenarios (issue #87)

  @knowledge_base_tool_list_400_01_perPage_exceeds_max
  Scenario: PerPage exceeds maximum allowed value
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools"
    And the query parameter "perPage" is set to 999
    When the request "listTools" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "OUT_OF_RANGE"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_tool_list_400_02_page_negative
  Scenario: Invalid negative page parameter
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools"
    And the query parameter "page" is set to -1
    When the request "listTools" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_tool_list_400_03_invalid_x_correlator
  Scenario: Invalid x-correlator header value
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools"
    And the header "x-correlator" is set to "invalid correlator!"
    When the request "listTools" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_tool_list_401_01_no_authorization_header
  Scenario: Error response for no header "Authorization"
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools"
    And the header "Authorization" is not sent
    When the request "listTools" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_tool_list_401_02_no_access_token
  Scenario: Error response for no access token in the "Authorization" header
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools"
    And the header "Authorization" is set to "Bearer"
    When the request "listTools" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_tool_list_401_03_expired_access_token
  Scenario: Error response for expired access token
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools"
    And the header "Authorization" is set to an expired access token
    When the request "listTools" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_tool_list_403_01_missing_scope
  Scenario: Missing access token scope
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools"
    And the header "Authorization" is set to an access token that does not include scope "knowledge-base:tools:read"
    When the request "listTools" is sent
    Then the response status code is 403
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_tool_list_404_01_not_found
  Scenario: non-existing knowledgeBaseId
    Given the path parameter "knowledgeBaseId" is set to a random UUID
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/tools"
    When the request "listTools" is sent
    Then the response status code is 404
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text
