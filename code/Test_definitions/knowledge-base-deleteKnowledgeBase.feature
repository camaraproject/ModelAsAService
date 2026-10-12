Feature: CAMARA MaaS Knowledge Base API, vwip - Operation deleteKnowledgeBase

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

  @knowledge_base_delete_01_success
  Scenario: Delete a knowledge base successfully
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    When the request "deleteKnowledgeBase" is sent
    Then the response status code is 204
    And the response header "x-correlator" has the same value as the request header "x-correlator"
