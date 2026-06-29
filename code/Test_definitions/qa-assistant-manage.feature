Feature: CAMARA MaaS QA Assistant Management API, v0.2.0-rc.1

    CAMARA Commonalities: 0.8.0

    # Input to be provided by the implementation to the tester
    #
    # Implementation indications:
    # * apiRoot: API root of the server URL
    #
    # Testing assets:
    # * As a developer, I want to test the management endpoints for QA assistants
    #   to ensure they handle CRUD operations and errors correctly.
    #
    # References to OAS spec schemas refer to schemas specified in qa-assistant-manage.yaml

  Background: Common QA assistant management setup
    Given an environment at "apiRoot"
    And the resource "/qa-assistant-manage/v0.2rc1/assistants"
    And the header "Content-Type" is set to "application/json"
    And the header "Authorization" is set to a valid access token
    And the header "x-correlator" complies with the schema at "#/components/schemas/XCorrelator"

  ############################ Happy Path Scenarios #############################################

  @qa_assistant_manage_create_01_success
  Scenario: Create a valid QA assistant
    And the request body is set by default to a request body compliant with the schema at "#/components/schemas/AssistantCreateRequest"
    When the request "createAssistant" is sent
    Then the response status code is 201
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/AssistantResponse"

  @qa_assistant_manage_create_02_with_tools
  Scenario: Create a QA assistant with associated tools
    Given an existing knowledge base created by operation "createKnowledgeBase" of the knowledge-base API
    And at least one existing tool created by operation "createTool" of the knowledge-base API, owned by that knowledge base
    And the request body property "$.knowledgeBaseId" is set to that knowledge base's ID
    And the request body property "$.toolIds" is set to an array containing that tool's UUID
    And the request body is compliant with the schema at "#/components/schemas/AssistantCreateRequest"
    When the request "createAssistant" is sent
    Then the response status code is 201
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/AssistantResponse"

  @qa_assistant_manage_get_02_includes_tool_ids
  Scenario: Get assistant response includes the configured toolIds
    Given an existing assistant created by operation "createAssistant" with knowledgeBaseId and toolIds
    And the path parameter "assistantId" is set to the value of the identifier for that assistant
    When the request "getAssistant" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response body complies with the OAS schema at "#/components/schemas/Assistant"
    And the response property "$.toolIds" is an array
    And the response property "$.toolIds" has a length greater than 0

  @qa_assistant_manage_update_02_add_tool
  Scenario: Update assistant to add a new tool
    Given an existing assistant created by operation "createAssistant"
    And at least one existing tool created by operation "createTool" of the knowledge-base API, owned by the assistant's knowledge base
    And the path parameter "assistantId" is set to the value of the identifier for that assistant
    And the request body property "$.toolIds" is set to an array containing the tool's UUID
    And the request body is compliant with the schema at "#/components/schemas/AssistantUpdateRequest"
    When the request "updateAssistant" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/AssistantResponse"

  @qa_assistant_manage_list_01_success
  Scenario: Retrieve all assistants
    Given at least an existing assistant created by operation "createAssistant"
    When the request "listAssistants" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.items" is an array whose items comply with the OAS schema at "#/components/schemas/Assistant"
    And the response property "$.pagination" complies with the OAS schema at "../common/CAMARA_common.yaml#/components/schemas/Pagination"

  @qa_assistant_manage_list_02_empty
  Scenario: No existing assistants
    Given no assistants have been created by operation "createAssistant"
    When the request "listAssistants" is sent
    Then the response status code is 200
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.items" is an empty array "[]"
    And the response property "$.pagination" complies with the OAS schema at "../common/CAMARA_common.yaml#/components/schemas/Pagination"

  @qa_assistant_manage_get_01_success
  Scenario: Get a specific assistant by ID
    Given an existing assistant created by operation "createAssistant"
    And the path parameter "assistantId" is set to the value of the identifier for that assistant
    When the request "getAssistant" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/Assistant"

  @qa_assistant_manage_update_01_success
  Scenario: Update an existing assistant
    Given an existing assistant created by operation "createAssistant"
    And the path parameter "assistantId" is set to the value of the identifier for that assistant
    And the request body is compliant with the schema at "#/components/schemas/AssistantUpdateRequest"
    When the request "updateAssistant" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/AssistantResponse"

  @qa_assistant_manage_delete_01_success
  Scenario: Delete an assistant successfully
    Given an existing assistant created by operation "createAssistant"
    And the path parameter "assistantId" is set to the value of the identifier for that assistant
    When the request "deleteAssistant" is sent
    Then the response status code is 204
    And the response header "x-correlator" has the same value as the request header "x-correlator"

  ############################ Error Scenarios #############################################

  # Syntax Error scenarios

  @qa_assistant_manage_create_400_01_schema_not_compliant
  Scenario: Invalid Argument. Generic Syntax Exception
    Given the request body is included but is not compliant with the schema at "#/components/schemas/AssistantCreateRequest"
    When the request "createAssistant" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @qa_assistant_manage_create_400_02_no_request_body
  Scenario: Missing request body
    Given the request body is not included
    When the request "createAssistant" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @qa_assistant_manage_create_400_03_empty_request_body
  Scenario: Empty object as request body
    Given the request body is set to {}
    When the request "createAssistant" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @qa_assistant_manage_create_400_04_missing_required_property
  Scenario: Error response for missing required property in request body
    Given the request body property "$.configurationPrompt" is not included
    When the request "createAssistant" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @qa_assistant_manage_create_400_05_out_of_range
  Scenario: Error response for out of range parameter
    Given the request body property "$.largeModelParameters.parameters.temperature" is set to a value outside the allowed range
    When the request "createAssistant" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "OUT_OF_RANGE"
    And the response property "$.message" contains a user friendly text

  # Pagination error scenarios

  @qa_assistant_manage_list_400_01_page_negative
  Scenario: Invalid negative page parameter
    Given the query parameter "page" is set to -1
    When the request "listAssistants" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"

  @qa_assistant_manage_list_400_02_perPage_exceeds_max
  Scenario: PerPage exceeds maximum allowed value
    Given the query parameter "perPage" is set to 999
    When the request "listAssistants" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "OUT_OF_RANGE"

  # Authentication/Authorization errors

  @qa_assistant_manage_401_01_no_authorization_header
  Scenario: Error response for no header "Authorization"
    Given the header "Authorization" is not sent
    When the request "listAssistants" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @qa_assistant_manage_401_02_expired_access_token
  Scenario: Error response for expired access token
    Given the header "Authorization" is set to an expired access token
    When the request "listAssistants" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @qa_assistant_manage_401_03_invalid_access_token
  Scenario: Error response for invalid access token
    Given the header "Authorization" is set to an invalid access token
    When the request "listAssistants" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  # Generic 403 errors

  @qa_assistant_manage_create_403_01_missing_scope
  Scenario: Missing access token scope
    Given the header "Authorization" is set to an access token that does not include scope "qa-assistant-manage:assistants:create"
    When the request "createAssistant" is sent
    Then the response status code is 403
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  # toolIds validation errors

  @qa_assistant_manage_create_400_06_invalid_tool_id_format
  Scenario: Create assistant with a malformed toolId (not a UUID)
    And the request body property "$.toolIds[0]" is set to "not-a-uuid"
    And the request body is compliant with the schema at "#/components/schemas/AssistantCreateRequest"
    When the request "createAssistant" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"

  @qa_assistant_manage_create_400_07_too_many_tool_ids
  Scenario: Create assistant with more than 100 toolIds
    And the request body property "$.toolIds" is set to an array of 101 distinct UUIDs
    And the request body is compliant with the schema at "#/components/schemas/AssistantCreateRequest"
    When the request "createAssistant" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "OUT_OF_RANGE"

  @qa_assistant_manage_create_400_08_duplicate_tool_ids
  Scenario: Create assistant with duplicate toolIds in the array
    And the request body property "$.toolIds" is set to ["<uuid>", "<uuid>"]
    And the request body is compliant with the schema at "#/components/schemas/AssistantCreateRequest"
    When the request "createAssistant" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"

  @qa_assistant_manage_create_422_01_tool_not_found
  Scenario: Create assistant with toolIds that do not exist in the knowledge base
    Given an existing knowledge base created by operation "createKnowledgeBase" of the knowledge-base API
    And the request body property "$.knowledgeBaseId" is set to that knowledge base's ID
    And the request body property "$.toolIds" is set to [a random UUID that does not exist]
    And the request body is compliant with the schema at "#/components/schemas/AssistantCreateRequest"
    When the request "createAssistant" is sent
    Then the response status code is 422
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 422
    And the response property "$.code" is "KNOWLEDGE_BASE.TOOL_NOT_FOUND"

  @qa_assistant_manage_create_422_02_tool_cross_kb
  Scenario: Create assistant with toolIds that belong to a different knowledge base
    Given an existing knowledge base "A" created by operation "createKnowledgeBase"
    And an existing knowledge base "B" created by operation "createKnowledgeBase"
    And an existing tool created by operation "createTool" owned by knowledge base "B"
    And the request body property "$.knowledgeBaseId" is set to knowledge base "A"'s ID
    And the request body property "$.toolIds" is set to [the tool's UUID]
    And the request body is compliant with the schema at "#/components/schemas/AssistantCreateRequest"
    When the request "createAssistant" is sent
    Then the response status code is 422
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 422
    And the response property "$.code" is "KNOWLEDGE_BASE.TOOL_CROSS_KB"

  @qa_assistant_manage_update_400_01_invalid_tool_id
  Scenario: Update assistant with a malformed toolId
    Given an existing assistant created by operation "createAssistant"
    And the path parameter "assistantId" is set to the value of the identifier for that assistant
    And the resource "/qa-assistant-manage/v0.2rc1/assistants/{assistantId}"
    And the request body property "$.toolIds[0]" is set to "not-a-uuid"
    And the request body is compliant with the schema at "#/components/schemas/AssistantUpdateRequest"
    When the request "updateAssistant" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"

  @qa_assistant_manage_update_422_01_tool_not_found
  Scenario: Update assistant with toolIds that do not exist
    Given an existing assistant created by operation "createAssistant"
    And the path parameter "assistantId" is set to the value of the identifier for that assistant
    And the resource "/qa-assistant-manage/v0.2rc1/assistants/{assistantId}"
    And the request body property "$.toolIds" is set to [a random UUID that does not exist]
    And the request body is compliant with the schema at "#/components/schemas/AssistantUpdateRequest"
    When the request "updateAssistant" is sent
    Then the response status code is 422
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 422
    And the response property "$.code" is "KNOWLEDGE_BASE.TOOL_NOT_FOUND"

  # Generic 404 Errors

  @qa_assistant_manage_get_404_01_not_found
  Scenario: non-existing assistantId
    Given the path parameter "assistantId" is set to a random UUID
    When the request "getAssistant" is sent
    Then the response status code is 404
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text

  @qa_assistant_manage_update_404_01_not_found
  Scenario: Update non-existing assistantId
    Given the path parameter "assistantId" is set to a random UUID
    And the request body is compliant with the schema at "#/components/schemas/AssistantUpdateRequest"
    When the request "updateAssistant" is sent
    Then the response status code is 404
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"

  @qa_assistant_manage_delete_404_01_not_found
  Scenario: Delete non-existing assistantId
    Given the path parameter "assistantId" is set to a random UUID
    When the request "deleteAssistant" is sent
    Then the response status code is 404
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"

  # Generic 500 Error

  @qa_assistant_manage_create_500_01_internal_error
  Scenario: Internal server error
    Given the system is in a faulty state
    When the request "createAssistant" is sent
    Then the response status code is 500
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.status" is 500
    And the response property "$.code" is "INTERNAL"
    And the response property "$.message" contains a user friendly text
