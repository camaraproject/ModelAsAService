Feature: CAMARA MaaS Knowledge Base API, v0.2.0 - Operation updateKnowledgeBase

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
    And the resource "/knowledge-base/v0.2/knowledge-bases"
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

  # Lifecycle / state verification scenarios (issue #87)

  @knowledge_base_update_02_patch_semantics
  Scenario Outline: PATCH semantics - provided field is replaced, omitted field is left unchanged
    Given an existing knowledge base created by operation "createKnowledgeBase" with name "original-name" and description "original-description"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the request body property "$.<updated_field>" is set to "<new_value>"
    And the request body is compliant with the schema at "#/components/schemas/KnowledgeBaseUpdateRequest"
    When the request "updateKnowledgeBase" is sent
    Then the response status code is 200
    And the response body complies with the OAS schema at "#/components/schemas/KnowledgeBase"
    And the response property "$.<updated_field>" is "<new_value>"
    And the response property "$.<preserved_field>" has the same value as before the update
    Examples:
      | updated_field | new_value        | preserved_field |
      | name          | patched-name     | description     |
      | description   | patched-desc     | name            |

  @knowledge_base_update_03_name_at_max_length_boundary
  Scenario: Value boundary - name of exactly 255 characters is accepted
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the request body property "$.name" is set to a string of 255 characters
    And the request body is compliant with the schema at "#/components/schemas/KnowledgeBaseUpdateRequest"
    When the request "updateKnowledgeBase" is sent
    Then the response status code is 200
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/KnowledgeBase"

  @knowledge_base_update_04_update_then_get_lifecycle
  Scenario: Update then get - the updated value is persisted and omitted fields are preserved
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And that knowledge base has been updated by operation "updateKnowledgeBase" with name "lifecycle-updated-name"
    When the request "getKnowledgeBase" is sent
    Then the response status code is 200
    And the response body complies with the OAS schema at "#/components/schemas/KnowledgeBase"
    And the response property "$.name" is "lifecycle-updated-name"
    And the response property "$.description" has the same value as before the update

  ############################ Error Scenarios #############################################

  # Syntax / validation errors

  @knowledge_base_update_400_01_empty_body
  Scenario: Update knowledge base with empty body (at least one field required)
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the request body is set to {}
    When the request "updateKnowledgeBase" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  # Common 403 error (PermissionDenied403)

  @knowledge_base_update_403_01_missing_scope
  Scenario: Update knowledge base with missing access token scope
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the header "Authorization" is set to an access token that does not include scope "knowledge-base:knowledge-bases:update"
    And the request body is compliant with the schema at "#/components/schemas/KnowledgeBaseUpdateRequest"
    When the request "updateKnowledgeBase" is sent
    Then the response status code is 403
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  # Common 404 error (NotFound404)

  @knowledge_base_update_404_01_not_found
  Scenario: Update non-existing knowledgeBaseId
    Given the path parameter "knowledgeBaseId" is set to a random UUID
    And the request body is compliant with the schema at "#/components/schemas/KnowledgeBaseUpdateRequest"
    When the request "updateKnowledgeBase" is sent
    Then the response status code is 404
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text

  # Common mandatory error scenarios (issue #87)

  @knowledge_base_update_400_02_no_request_body
  Scenario: Missing request body on update
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the request body is not included
    When the request "updateKnowledgeBase" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_update_400_03_unknown_top_level_property
  Scenario: Request body strictness - undeclared property is rejected
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the request body is compliant with the schema at "#/components/schemas/KnowledgeBaseUpdateRequest"
    And the request body property "$.unknownProperty" is set to "value"
    When the request "updateKnowledgeBase" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_update_400_04_invalid_x_correlator
  Scenario: Invalid x-correlator header value
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the request body is compliant with the schema at "#/components/schemas/KnowledgeBaseUpdateRequest"
    And the header "x-correlator" is set to "invalid correlator!"
    When the request "updateKnowledgeBase" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_update_400_05_name_exceeds_max_length
  Scenario: Value boundary - name exceeds maxLength 255
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the request body property "$.name" is set to a string of 256 characters
    When the request "updateKnowledgeBase" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_update_400_06_description_exceeds_max_length
  Scenario: Value boundary - description exceeds maxLength 4096
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the request body property "$.description" is set to a string of 4097 characters
    When the request "updateKnowledgeBase" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_update_400_07_malformed_knowledge_base_id
  Scenario: Invalid Argument. Malformed knowledgeBaseId (not a UUID)
    Given the path parameter "knowledgeBaseId" is set to "not-a-uuid"
    And the request body is compliant with the schema at "#/components/schemas/KnowledgeBaseUpdateRequest"
    When the request "updateKnowledgeBase" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_update_401_01_no_authorization_header
  Scenario: Error response for no header "Authorization"
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the request body is compliant with the schema at "#/components/schemas/KnowledgeBaseUpdateRequest"
    And the header "Authorization" is not sent
    When the request "updateKnowledgeBase" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_update_401_02_no_access_token
  Scenario: Error response for no access token in the "Authorization" header
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the request body is compliant with the schema at "#/components/schemas/KnowledgeBaseUpdateRequest"
    And the header "Authorization" is set to "Bearer"
    When the request "updateKnowledgeBase" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @knowledge_base_update_401_03_expired_access_token
  Scenario: Error response for expired access token
    Given an existing knowledge base created by operation "createKnowledgeBase"
    And the path parameter "knowledgeBaseId" is set to the value of the identifier for that knowledge base
    And the request body is compliant with the schema at "#/components/schemas/KnowledgeBaseUpdateRequest"
    And the header "Authorization" is set to an expired access token
    When the request "updateKnowledgeBase" is sent
    Then the response status code is 401
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text
