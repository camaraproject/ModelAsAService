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

  ############################ Error Scenarios #############################################

  @knowledge_base_upload_document_400_01_invalid_format
  Scenario: Upload document with unsupported format
    Given the request body contains an unsupported document format
    When the request "uploadDocument" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  # Error 415 (UnsupportedMediaType415)
  @knowledge_base_upload_document_415_01_unsupported_media_type
  Scenario: Unsupported media type for document upload
    Given the request has a payload format in an unsupported format
    When the request "uploadDocument" is sent
    Then the response status code is 415
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 415
    And the response property "$.code" is "UNSUPPORTED_MEDIA_TYPE"
    And the response property "$.message" contains a user friendly text
