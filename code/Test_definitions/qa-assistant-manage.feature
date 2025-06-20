Feature: QA Assistant Management API Testing
  As a developer or QA engineer
  I want to test the management endpoints for QA assistants
  To ensure they handle CRUD operations and errors correctly

  Background:
    Given the QA Assistant Management API is running
    And an existing assistant with ID "a1b2c3d4" exists (for update/delete tests)

  @positive
  Scenario: Create a valid QA assistant
    When the user sends a POST request to "/assistants" with:
      | name               | "Tech Support"          |
      | description        | "Handles technical issues" |
      | knowledgeBaseId    | "kb_tech"               |
      | configurationPrompt| "Answer using KB, be concise" |
      | largeModelParameters | 
        | model | "gpt-4" |
        | parameters | {"temperature": 0.3, "max_tokens": 150} |
      | openingRemarks | "Hello! How can I assist?" |
    Then the response status code should be 201
    And the response body should contain:
      | success | true  |
      | assistantId | "a1b2c3d4" (or any UUID) |
      | message | "Assistant created successfully" |

  @negative
  Scenario: Create assistant with missing required parameters
    When the user sends a POST request without "configurationPrompt":
      | name | "Invalid Assistant" |
      | largeModelParameters | {"model": "gpt-3", "parameters": {}} |
    Then the response status code should be 400
    And the error message should be "Missing required parameter 'configurationPrompt'"

  @positive
  Scenario: Retrieve all assistants
    When the user sends a GET request to "/assistants"
    Then the response status code should be 200
    And the response body should be an array of assistant objects
    And each object contains "assistantId", "name", and "configurationPrompt"

  @negative
  Scenario: Get non-existent assistant returns 404
    When the user sends a GET request to "/assistants/invalid-id"
    Then the response status code should be 404
    And the error message should be "Assistant not found"

  @positive
  Scenario: Update an existing assistant
    Given an existing assistant with ID "a1b2c3d4"
    When the user sends a PUT request to "/assistants/a1b2c3d4" with:
      | name | "Support Bot" |
      | configurationPrompt | "Answer more detailed" |
      | largeModelParameters | {"model": "gpt-4", "parameters": {"temperature": 0.5}} |
    Then the response status code should be 200
    And the updated assistant's "name" is "Support Bot"

  @negative
  Scenario: Update with invalid model parameters
    When the user sends a PUT request with invalid temperature:
      | assistantId | "a1b2c3d4" |
      | largeModelParameters | {"parameters": {"temperature": 1.5}} |
    Then the response status code should be 400
    And the error message includes "Invalid model parameter 'temperature'"

  @positive
  Scenario: Delete an assistant successfully
    When the user sends a DELETE request to "/assistants/a1b2c3d4"
    Then the response status code should be 204
    And subsequent GET for "a1b2c3d4" returns 404

  @negative
  Scenario: Delete non-existent assistant returns 404
    When the user sends a DELETE request to "/assistants/nonexistent"
    Then the response status code should be 404
    And the error message is "Assistant not found"