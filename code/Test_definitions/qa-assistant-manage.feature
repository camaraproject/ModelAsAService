Feature: CAMARA MaaS QA Assistant Management API, v0.1.0
    # Input to be provided by the implementation to the tester
    #
    # Implementation indications:
    # * apiRoot: API root of the server URL
    #
    # Testing assets:
    # * As a developer or QA engineer, I want to test the management endpoints for QA assistants to ensure they handle CRUD operations and errors correctly.
    #
    # References to OAS spec schemas refer to schemas specified in knowledge-base.yaml

  Background: Common knowledge-base setup
    Given an environment at "apiRoot"
    And the resource "/qa-assistant-manage/v0.1"                                                              |
    And the header "Content-Type" is set to "application/json"
    And the header "Authorization" is set to a valid access token
    And the header "x-correlator" complies with the schema at "#/components/schemas/XCorrelator"
    And an existing assistant with ID "a1b2c3d4" exists (for update/delete tests)

  @qa_assistant_manage_create_sucess
  Scenario: Create a valid QA assistant
    When the user sends a POST request to "/assistants" with:
      | name               | "Tech Support"          |
      | description        | "Handles technical issues" |
      | knowledgeBaseId    | "kb_tech"               |
      | configurationPrompt| "Answer using KB, be concise" |
      | largeModelParameters | {"model": "gpt-4", "parameters": {"temperature": 0.3, "max_tokens": 150}} |
      | openingRemarks | "Hello! How can I assist?" |
    Then the response status code should be 201
    And the response body should contain:
      | success | true  |
      | assistantId | "a1b2c3d4" (or any UUID) |
      | message | "Assistant created successfully" |

  @qa_assistant_manage_create_fail_missing_parameters
  Scenario: Create assistant with missing required parameters
    When the user sends a POST request without "configurationPrompt":
      | name | "Invalid Assistant" |
      | largeModelParameters | {"model": "gpt-3", "parameters": {}} |
    Then the response status code should be 400
    And the error message should be "Missing required parameter 'configurationPrompt'"

  @qa_assistant_manage_get_all
  Scenario: Retrieve all assistants
    When the user sends a GET request to "/assistants"
    Then the response status code should be 200
    And the response body should be an array of assistant objects
    And each object contains "assistantId", "name", and "configurationPrompt"

  @qa_assistant_manage_get_fail_not_exist
  Scenario: Get non-existent assistant returns 404
    When the user sends a GET request to "/assistants/invalid-id"
    Then the response status code should be 404
    And the error message should be "Assistant not found"

  @qa_assistant_manage_update_sucess
  Scenario: Update an existing assistant
    Given an existing assistant with ID "a1b2c3d4"
    When the user sends a PUT request to "/assistants/a1b2c3d4" with:
      | name | "Support Bot" |
      | configurationPrompt | "Answer more detailed" |
      | largeModelParameters | {"model": "gpt-4", "parameters": {"temperature": 0.5}} |
    Then the response status code should be 200
    And the updated assistant's "name" is "Support Bot"

  @qa_assistant_manage_update_fail_invalid_parameters
  Scenario: Update with invalid model parameters
    When the user sends a PUT request with invalid temperature:
      | assistantId | "a1b2c3d4" |
      | largeModelParameters | {"parameters": {"temperature": 1.5}} |
    Then the response status code should be 400
    And the error message includes "Invalid model parameter 'temperature'"

  @qa_assistant_manage_delete_sucess
  Scenario: Delete an assistant successfully
    When the user sends a DELETE request to "/assistants/a1b2c3d4"
    Then the response status code should be 204
    And subsequent GET for "a1b2c3d4" returns 404

  @qa_assistant_manage_delete_fail_not_exist
  Scenario: Delete non-existent assistant returns 404
    When the user sends a DELETE request to "/assistants/nonexistent"
    Then the response status code should be 404
    And the error message is "Assistant not found"
