Feature: CAMARA MaaS Knowledge Base API, vwip - Operation uploadDocument

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

  @knowledge_base_upload_document_01_success
  Scenario: Upload valid document to knowledge base
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/documents"
    And a valid document file with format pdf is available
    When the request "uploadDocument" is sent
    Then the response status code is 201
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Location" is present
    And the response body complies with the OAS schema at "#/components/schemas/Document"
    And the response property "$.documentId" is present
    And the response property "$.status" is one of "PROCESSING", "READY", "FAILED"

  # Lifecycle / state verification scenarios (issue #87)

  @knowledge_base_upload_document_02_processing_status
  Scenario Outline: Upload document - all three processing_status values are observable
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/documents"
    And the document indexing for this upload is configured to end with status "<processing_status>"
    And a valid document file with format pdf is available
    When the request "uploadDocument" is sent
    Then the response status code is 201
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/Document"
    And the response property "$.status" is "<processing_status>"
    Examples:
      | processing_status |
      | PROCESSING        |
      | READY             |
      | FAILED            |

  @knowledge_base_upload_document_03_upload_then_get_lifecycle
  Scenario: Upload then get - the created document is retrievable
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And an existing document created by operation "uploadDocument"
    And the path parameter "documentId" is set to the value of the identifier for that document
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/documents/{documentId}"
    When the request "getDocument" is sent
    Then the response status code is 200
    And the response body complies with the OAS schema at "#/components/schemas/Document"
    And the response property "$.documentId" has the same value as the identifier of that document
    And the response property "$.status" is one of "PROCESSING", "READY", "FAILED"

  ############################ Error Scenarios #############################################

  @knowledge_base_upload_document_400_01_invalid_format
  Scenario: Invalid document file format in the multipart "document" part (400)
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/documents"
    And the request body's "document" form part contains a file whose format is not one of "DOC", "PDF", "TXT", "CSV"
    When the request "uploadDocument" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  # Error 415 (UnsupportedMediaType415) - unsupported request MIME type, NOT the document file format
  @knowledge_base_upload_document_415_01_unsupported_media_type
  Scenario: Unsupported MIME type for document upload (415)
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/documents"
    And the request "Content-Type" header is set to "application/xml" instead of "multipart/form-data"
    And a valid document file with format pdf is available
    When the request "uploadDocument" is sent
    Then the response status code is 415
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 415
    And the response property "$.code" is "UNSUPPORTED_MEDIA_TYPE"
    And the response property "$.message" contains a user friendly text

  # Common mandatory error scenarios (issue #87)

  @knowledge_base_upload_document_400_02_undeclared_form_part
  Scenario: Request body strictness - undeclared multipart form part is rejected
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/documents"
    And the request body contains an undeclared form part "metadata" in addition to "document"
    And a valid document file with format pdf is available
    When the request "uploadDocument" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_upload_document_400_03_invalid_x_correlator
  Scenario: Invalid x-correlator header value
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/documents"
    And a valid document file with format pdf is available
    And the header "x-correlator" is set to "invalid correlator!"
    When the request "uploadDocument" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_upload_document_401_01_no_authorization_header
  Scenario: Error response for no header "Authorization"
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/documents"
    And a valid document file with format pdf is available
    And the header "Authorization" is not sent
    When the request "uploadDocument" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_upload_document_401_02_no_access_token
  Scenario: Error response for no access token in the "Authorization" header
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/documents"
    And a valid document file with format pdf is available
    And the header "Authorization" is set to "Bearer"
    When the request "uploadDocument" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_upload_document_401_03_expired_access_token
  Scenario: Error response for expired access token
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/documents"
    And a valid document file with format pdf is available
    And the header "Authorization" is set to an expired access token
    When the request "uploadDocument" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_upload_document_403_01_missing_scope
  Scenario: Missing access token scope
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/documents"
    And a valid document file with format pdf is available
    And the header "Authorization" is set to an access token that does not include scope "knowledge-base:documents:create"
    When the request "uploadDocument" is sent
    Then the response status code is 403
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_upload_document_404_01_not_found
  Scenario: non-existing knowledgeBaseId
    Given the path parameter "knowledgeBaseId" is set to a random UUID
    And the resource "/knowledge-base/vwip/knowledge-bases/{knowledgeBaseId}/documents"
    And a valid document file with format pdf is available
    When the request "uploadDocument" is sent
    Then the response status code is 404
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text
