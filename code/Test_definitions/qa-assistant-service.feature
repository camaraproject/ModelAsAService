Feature: CAMARA MaaS Q&A Assistant Service API, v0.1.0
    # Input to be provided by the implementation to the tester
    #
    # Implementation indications:
    # * apiRoot: API root of the server URL
    #
    # Testing assets:
    # * As a user, I want to query answers using a specified QA assistant and knowledge base.
    #
    # References to OAS spec schemas refer to schemas specified in knowledge-base.yaml

  Background: Common knowledge-base setup
    Given an environment at "apiRoot"
    And the resource "/qa-assistant-service/v0.1"                                                              |
    And the header "Content-Type" is set to "application/json"
    And the header "Authorization" is set to a valid access token
    And the header "x-correlator" complies with the schema at "#/components/schemas/XCorrelator"

  @qa_assistant_service_get_answer_sucess
  Scenario: Get a valid answer successfully
    Given the assistant with ID "a1b2c3d4" exists
    When the user sends a POST request to "/answer" with valid parameters:
      """
      {
        "assistantId": "a1b2c3d4",
        "prompt": "What is the return policy?"
      }
      """
    Then the response status code should be 200
    And the response should contain:
      | success | finished | answerText | reference (optional) |
      | true    | Stop     | "..."      | (may be present)     |

  @qa_assistant_service_get_answer_fail_missing_assistant_id
  Scenario: Request with missing 'assistantId' parameter
    Given the request body lacks the 'assistantId' field
    When sending a POST request to "/answer"
    Then the response status code should be 400
    And the error response should indicate "Missing required parameter 'assistantId'"

  @qa_assistant_service_get_answer_fail_missing_prompt
  Scenario: Request with missing 'prompt' parameter
    Given the request body lacks the 'prompt' field
    When sending a POST request to "/answer"
    Then the response status code should be 400
    And the error response should indicate "Missing required parameter 'prompt'"

  @qa_assistant_service_get_answer_fail_assistant_not_found
  Scenario: Assistant not found error
    When the user sends a POST request to "/answer" with:
      """
      {
        "assistantId": "invalid-id",
        "prompt": "How to reset password?"
      }
      """
    Then the response status code should be 404
    And the error message should be "Assistant with ID 'invalid-id' does not exist"

  @qa_assistant_service_get_answer_fail_token_limit
  Scenario: Answer truncated due to token limit
    Given the assistant's response exceeds the token limit
    When sending a valid query request
    Then the response should have:
      | finished | answerText | success |
      | Length   | "Partial answer..." | true |

  @qa_assistant_service_get_answer_fail_model_timeout
  Scenario: Response generation error
    Given the assistant encounters an internal error during processing
    When sending a valid query request
    Then the response should have:
      | finished | success | error.code | error.message |
      | Error    | false   | 500        | "Model processing timeout" |

  @qa_assistant_service_get_answer_fail_block
  Scenario: Content filter blocks answer
    Given the generated answer triggers content filter
    When sending a valid query request
    Then the response should have:
      | finished | answerText | success |
      | Filter   | ""         | false  |

  @qa_assistant_service_get_answer_fail_server_error
  Scenario: Server error during processing
    Given the backend service is malfunctioning
    When sending any valid query request
    Then the response status code should be 500
    And the error message should indicate server-side failure

  @qa_assistant_service_get_answer_sucess_reference
  Scenario: Reference field present in response
    Given the knowledge base contains relevant documentation for the query
    When querying with a valid request
    Then the response should include a "reference" field like "kb123_section5"

  @qa_assistant_service_get_answer_empty_answer
  Scenario: Empty answer with successful status
    Given the query has no applicable answer but processing succeeded
    When sending a valid request
    Then "answerText" is empty string
    And "finished" is "Stop"
    And "success" is true

  @qa_assistant_service_get_answer_sucess_all
  Scenario: Validate all required fields in response
    When receiving a successful response
    Then the response must contain: "success", "finished" and "answerText"
    And may optionally contain "reference" and "error" fields
