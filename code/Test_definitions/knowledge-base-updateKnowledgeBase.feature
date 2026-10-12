Feature: CAMARA MaaS Knowledge Base API, vwip - Operation updateKnowledgeBase

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
