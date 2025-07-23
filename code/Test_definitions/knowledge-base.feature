Feature: CAMARA MaaS Knowledge base API, v0.1.0-rc.1
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
    And the resource "/knowledge-base/v0.1rc1"                                                              |
    And the header "Content-Type" is set to "application/json"
    And the header "Authorization" is set to a valid access token
    And the header "x-correlator" complies with the schema at "#/components/schemas/XCorrelator"

  @api
  Scenario: Create a new knowledge base successfully
    Given the user sends a POST request to "/knowledge-bases" with valid JSON payload:
      """
      {
        "name": "Test Knowledge Base",
        "description": "This is a test knowledge base for automation."
      }
      """
    When the API processes the request
    Then the response status code should be 201
    And the response should contain a "knowledgeBaseId" field
    And the response should include "name" and "description" fields matching the request

  @api
  Scenario: Create knowledge base with missing required field "name"
    Given the user sends a POST request to "/knowledge-bases" with invalid JSON payload:
      """
      {
        "description": "Missing name field"
      }
      """
    When the API processes the request
    Then the response status code should be 400
    And the response body should contain an error message about missing required field

  @api
  Scenario: Get all knowledge bases
    Given there are existing knowledge bases in the system
    When the user sends a GET request to "/knowledge-bases"
    Then the response status code should be 200
    And the response should return an array of knowledge base objects
    And each object should contain "knowledgeBaseId", "name", and "description"

  @api
  Scenario: Get a specific knowledge base by ID
    Given there exists a knowledge base with ID "kb-123"
    When the user sends a GET request to "/knowledge-bases/kb-123"
    Then the response status code should be 200
    And the response should contain the knowledge base details with "kb-123" as ID

  @api
  Scenario: Get non-existent knowledge base
    When the user sends a GET request to "/knowledge-bases/non-existing-id"
    Then the response status code should be 404
    And the response body should contain a "Not Found" error message

  @api
  Scenario: Update an existing knowledge base
    Given there exists a knowledge base with ID "kb-456"
    When the user sends a PUT request to "/knowledge-bases/kb-456" with JSON payload:
      """
      {
        "name": "Updated Name",
        "description": "Updated description"
      }
      """
    Then the response status code should be 200
    And the response should show the updated name and description

  @api
  Scenario: Update knowledge base with invalid ID
    When the user sends a PUT request to "/knowledge-bases/invalid-id"
    Then the response status code should be 404

  @api
  Scenario: Delete a knowledge base successfully
    Given there exists a knowledge base with ID "kb-789"
    When the user sends a DELETE request to "/knowledge-bases/kb-789"
    Then the response status code should be 204
    And the knowledge base should no longer appear in the list when queried

  @api
  Scenario: Upload valid document to knowledge base
    Given there exists a knowledge base with ID "kb-101"
    And a valid document file "test_document.pdf" is available
    When the user sends a POST request to "/knowledge-bases/kb-101/documents" with multipart/form-data containing the document
    Then the response status code should be 201
    And the response body should contain a success message

  @api
  Scenario: Upload invalid document format
    Given there exists a knowledge base with ID "kb-202"
    And an invalid document file "test_image.jpg" is available
    When the user sends a POST request to "/knowledge-bases/kb-202/documents" with the invalid file
    Then the response status code should be 400
    And the error message should mention unsupported format

  @api
  Scenario: Upload document to non-existent knowledge base
    When the user sends a POST request to "/knowledge-bases/invalid-id/documents" with a valid document
    Then the response status code should be 404

  @api
  Scenario: Server error handling (negative test)
    Given the system is in a faulty state
    When performing any API operation (e.g., POST to /knowledge-bases)
    Then the response status code should be 500
    And the error response should contain server error details
