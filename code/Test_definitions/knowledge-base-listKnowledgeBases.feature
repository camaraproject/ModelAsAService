Feature: CAMARA MaaS Knowledge Base API, v0.2.0-rc.2 - Operation listKnowledgeBases

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

  @knowledge_base_list_01_success
  Scenario: Get all knowledge bases successfully
    Given at least an existing knowledge base created by operation "createKnowledgeBase"
    When the request "listKnowledgeBases" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.items" is an array whose items comply with the OAS schema at "#/components/schemas/KnowledgeBase"
    And the response property "$.pagination" complies with the OAS schema at "#/components/schemas/Pagination"

  @knowledge_base_list_02_empty
  Scenario: Get all knowledge bases when none exist
    Given no knowledge bases have been created by operation "createKnowledgeBase"
    When the request "listKnowledgeBases" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.items" is an empty array "[]"
    And the response property "$.pagination" complies with the OAS schema at "#/components/schemas/Pagination"

  ############################ Error Scenarios #############################################

  # Pagination error scenarios
  @knowledge_base_list_400_01_perPage_exceeds_max
  Scenario: PerPage exceeds maximum allowed value
    Given the query parameter "perPage" is set to 999
    When the request "listKnowledgeBases" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "OUT_OF_RANGE"

  # Authentication/Authorization errors
  @knowledge_base_401_01_expired_access_token
  Scenario: Error response for expired access token
    Given the header "Authorization" is set to an expired access token
    When the request "listKnowledgeBases" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text
