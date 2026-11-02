Feature: CAMARA MaaS Knowledge Base API, v0.2.0-rc.2 - Operation listTools

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

  @knowledge_base_tool_list_01_success
  Scenario: List tools successfully
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/v0.2rc2/knowledge-bases/{knowledgeBaseId}/tools"
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
    And the resource "/knowledge-base/v0.2rc2/knowledge-bases/{knowledgeBaseId}/tools"
    And no tools have been created by operation "createTool"
    When the request "listTools" is sent
    Then the response status code is 200
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.items" is an empty array "[]"
    And the response property "$.pagination" complies with the OAS schema at "#/components/schemas/Pagination"
