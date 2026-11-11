Feature: CAMARA MaaS Knowledge Base API, vwip - Operation deleteDocument

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

  @knowledge_base_delete_document_01_success
  Scenario: Delete a document successfully
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing document created by operation "uploadDocument"
    And the path parameter "documentId" is set to the value of the identifier for that document
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/documents/{documentId}"
    When the request "deleteDocument" is sent
    Then the response status code is 204
    And the response header "x-correlator" has the same value as the request header "x-correlator"

  ############################ Error Scenarios #############################################

  @knowledge_base_delete_document_404_01_not_found
  Scenario: Delete a non-existing document
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the path parameter "documentId" is set to a random UUID
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/documents/{documentId}"
    When the request "deleteDocument" is sent
    Then the response status code is 404
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text

  # Common mandatory error scenarios (issue #87)

  @knowledge_base_delete_document_400_01_malformed_document_id
  Scenario: Invalid Argument. Malformed documentId (not a UUID)
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the path parameter "documentId" is set to "not-a-uuid"
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/documents/{documentId}"
    When the request "deleteDocument" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_delete_document_400_02_invalid_x_correlator
  Scenario: Invalid x-correlator header value
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing document created by operation "uploadDocument"
    And the path parameter "documentId" is set to the value of the identifier for that document
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/documents/{documentId}"
    And the header "x-correlator" is set to "invalid correlator!"
    When the request "deleteDocument" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_delete_document_401_01_no_authorization_header
  Scenario: Error response for no header "Authorization"
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing document created by operation "uploadDocument"
    And the path parameter "documentId" is set to the value of the identifier for that document
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/documents/{documentId}"
    And the header "Authorization" is not sent
    When the request "deleteDocument" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_delete_document_401_02_no_access_token
  Scenario: Error response for no access token in the "Authorization" header
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing document created by operation "uploadDocument"
    And the path parameter "documentId" is set to the value of the identifier for that document
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/documents/{documentId}"
    And the header "Authorization" is set to "Bearer"
    When the request "deleteDocument" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_delete_document_401_03_expired_access_token
  Scenario: Error response for expired access token
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing document created by operation "uploadDocument"
    And the path parameter "documentId" is set to the value of the identifier for that document
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/documents/{documentId}"
    And the header "Authorization" is set to an expired access token
    When the request "deleteDocument" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_delete_document_403_01_missing_scope
  Scenario: Missing access token scope
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing document created by operation "uploadDocument"
    And the path parameter "documentId" is set to the value of the identifier for that document
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/documents/{documentId}"
    And the header "Authorization" is set to an access token that does not include scope "knowledge-base:documents:delete"
    When the request "deleteDocument" is sent
    Then the response status code is 403
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_delete_document_404_02_after_delete_get_not_found
  Scenario: Delete then get - the deleted resource is no longer retrievable
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing document created by operation "uploadDocument"
    And the path parameter "documentId" is set to the value of the identifier for that document
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/documents/{documentId}"
    And that document has been deleted by operation "deleteDocument"
    When the request "getDocument" is sent
    Then the response status code is 404
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text
