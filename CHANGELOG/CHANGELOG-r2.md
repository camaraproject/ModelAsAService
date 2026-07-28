# Changelog ModelAsAService

<!-- TOC:START -->
## Table of Contents
- [r2.1](#r21)
<!-- TOC:END -->

**Please be aware that the project will have frequent updates to the main branch. There are no compatibility guarantees associated with code in any branch, including main, until it has been released. For example, changes may be reverted before a release is published. For the best results, use the latest published release.**

The below sections record the changes for each API version in each release as follows:

* for an alpha release, the delta with respect to the previous release
* for the first release-candidate, all changes since the last public release
* for subsequent release-candidate(s), only the delta to the previous release-candidate
* for a public release, the consolidated changes since the previous public release

# r2.1

## Release Notes

This release candidate contains the definition and documentation of
* knowledge-base 0.2.0-rc.1
* qa-assistant-manage 0.2.0-rc.1
* qa-assistant-service 0.2.0-rc.1

The API definition(s) are based on
* Commonalities 0.8.0
* Identity and Consent Management 0.5.0

## knowledge-base 0.2.0-rc.1

**knowledge-base 0.2.0-rc.1 is a release-candidate version of this API.**

Changes documented below are compared to version 0.1.0.

- API definition **with inline documentation**:
  - [View it on ReDoc](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/ModelAsAService/r2.1/code/API_definitions/knowledge-base.yaml&nocors)
  - [View it on Swagger Editor](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/ModelAsAService/r2.1/code/API_definitions/knowledge-base.yaml)
  - OpenAPI [YAML spec file](https://github.com/camaraproject/ModelAsAService/blob/r2.1/code/API_definitions/knowledge-base.yaml)

### Breaking changes

- API-specific error codes renamed to align with the Commonalities `{{API_NAME}}.{{SPECIFIC_CODE}}` format (issue [#38](https://github.com/camaraproject/ModelAsAService/issues/38)). The API name is `knowledge-base`, so all API-specific codes are now prefixed with `KNOWLEDGE_BASE.` and the specific code is a single SCREAMING_SNAKE_CASE token:
  - `TOOL.INVALID_INPUT` -> `KNOWLEDGE_BASE.TOOL_INVALID_INPUT`
  - `TOOL.DISABLED` -> `KNOWLEDGE_BASE.TOOL_DISABLED`
  - `TOOL.EXECUTION_FAILED` -> `KNOWLEDGE_BASE.TOOL_EXECUTION_FAILED`
  - `TOOL.TIMEOUT` -> `KNOWLEDGE_BASE.TOOL_TIMEOUT`
  - The renamed codes appear both in the HTTP 422 `ToolInvalidInput422` response (`code` enum) and in the HTTP 200 `ToolCallResponse.contextCode` enum.
- The `headers` field of a tool is now `writeOnly: true` (issue [#41](https://github.com/camaraproject/ModelAsAService/issues/41)). It is still accepted on `createTool` and `updateTool` requests, but is no longer returned by `getTool` or `listTools`. This prevents secret-bearing header values (e.g. API keys in `X-Api-Key`) from being read back by callers holding the broader `knowledge-base:tools:read` scope. API consumers MUST NOT rely on reading back stored header values; the platform stores them securely and injects them only when invoking the tool. The `headers` field example was also updated from the forbidden `Authorization: Bearer {{token}}` to `X-Api-Key: '{{apiKey}}'`.
- The `callTool` operation no longer returns HTTP 429 for upstream tool rate-limiting (issue [#44](https://github.com/camaraproject/ModelAsAService/issues/44)). Upstream tool outcomes - including rate-limit (HTTP 429 from the tool) and failures (HTTP 5xx from the tool) - are now consistently reported through the HTTP 200 `ToolCallResponse` envelope (`success=false`, `statusCode` mirrors the upstream status, `contextCode` identifies the reason, e.g. `KNOWLEDGE_BASE.TOOL_RATE_LIMITED` / `KNOWLEDGE_BASE.TOOL_EXECUTION_FAILED`), per the business-outcome modelling in CAMARA API Design Guide §3.1. The `500` response is retained only for platform-internal errors, not upstream failures. API consumers that relied on HTTP 429 to detect upstream rate-limiting MUST instead inspect the 200 envelope's `contextCode`.
- Removed `KNOWLEDGE_BASE.TOOL_INVALID_INPUT` and `KNOWLEDGE_BASE.TOOL_DISABLED` from the `ToolCallResponse.contextCode` enum (issue [#45](https://github.com/camaraproject/ModelAsAService/issues/45)). These two conditions (semantically invalid arguments, disabled tool) are now reported exclusively through HTTP 422 `ToolInvalidInput422` (pre-invocation checks), while the `contextCode` enum is reserved for outcomes of the actual upstream tool invocation (`KNOWLEDGE_BASE.TOOL_EXECUTION_FAILED`, `KNOWLEDGE_BASE.TOOL_TIMEOUT`, `KNOWLEDGE_BASE.TOOL_RATE_LIMITED`). This gives each condition exactly one response channel, so implementations cannot choose between 422 and the 200 envelope for the same condition. API consumers that inspected the 200 envelope's `contextCode` for these two values MUST instead handle the HTTP 422 response.
- The `uploadDocument` 201 response body is replaced by a `Document` resource (issue [#48](https://github.com/camaraproject/ModelAsAService/issues/48)). The previous body was a `{ "message": "Document uploaded successfully" }` confirmation object with no identifier; the new body is the `Document` schema (`documentId`, `knowledgeBaseId`, `filename`, `format`, `uploadDate`, `status`). A `Location` response header pointing at `GET /knowledge-bases/{knowledgeBaseId}/documents/{documentId}` is also added. API consumers that read the `message` field MUST update to the new `Document` body; consumers that needed a handle to the uploaded document now use `documentId` / `Location`.

### Added

- New API-specific context code `KNOWLEDGE_BASE.TOOL_RATE_LIMITED` added to the `ToolCallResponse.contextCode` enum, aligned with the renamed format and the existing test assertion for upstream rate-limit outcomes (issue [#38](https://github.com/camaraproject/ModelAsAService/issues/38)).
- Documented the intended tool usage model in the `createTool` and `callTool` operation descriptions: tools registered under a knowledge base may be associated with a Q&A assistant via `qa-assistant-manage`, and the assistant's LLM may invoke them automatically during answer generation; `callTool` is the API consumer-facing execution channel for testing a registered tool through the platform's execution path before associating it with an assistant (issue [#39](https://github.com/camaraproject/ModelAsAService/issues/39)).
- Documented security considerations for server-side outbound requests to tool URLs (callTool and LLM-initiated tool invocations): the API provider MUST enforce SSRF protections - URL scheme restricted to `https`, destination address blocklist (private/loopback/link-local ranges and cloud metadata endpoints), port allow-list, no redirect following unless re-validated, bounded response size and timeouts. The `url` field is constrained to `https` via a `pattern` and its description references the security constraints; the `callTool` description reiterates the security note (issue [#40](https://github.com/camaraproject/ModelAsAService/issues/40)).
- Documented the tool call authentication model in the `headers` field description and the `callTool` operation description (issue [#42](https://github.com/camaraproject/ModelAsAService/issues/42)): credentials for authenticating the outbound tool call to the upstream tool MUST be supplied through non-reserved custom headers (e.g. `X-Api-Key`, `X-Auth-Token`) and MUST NOT be placed in the reserved `Authorization` header; excluding `Authorization` is deliberate (the platform may need to set it itself, and consumer-supplied values would create an ambiguity). Because `headers` is `writeOnly` (see issue #41), credentials are accepted on write and never returned on read. A structured credential model (e.g. the CAMARA `sinkCredential` pattern) is not adopted in this API version; it may be evaluated for a future release.
- Documented HTTP 409 responses for `createKnowledgeBase`, `createTool` and `updateTool` (issue [#46](https://github.com/camaraproject/ModelAsAService/issues/46)): `createKnowledgeBase` and `createTool` return `409 ALREADY_EXISTS` when the `name` violates the documented uniqueness rule; `updateTool` returns `409 ABORTED` on concurrent modification. Both codes are standard CAMARA error codes already present in `Generic409`. This aligns the API definitions with the existing test scenarios `@knowledge_base_tool_create_409_01_duplicate_name` and `@knowledge_base_tool_update_409_01_concurrent_modification`.
- Modelled documents as a sub-resource of the knowledge base, with their own identifier and lifecycle (issue [#48](https://github.com/camaraproject/ModelAsAService/issues/48)):
  - New `Document` schema (`documentId`, `knowledgeBaseId`, `filename`, `format`, `uploadDate`, `status`) shared by the `uploadDocument` 201 response, the new `getDocument` 200 response, and the `KnowledgeBase.documents` embedded array (the array items now `$ref` the same `Document` schema, so the three representations are consistent).
  - New `status` field on documents (`PROCESSING` / `READY` / `FAILED`) reflecting asynchronous indexing; only documents with `status = READY` participate in answer generation via `queryAssistant` on the `qa-assistant-service` API.
  - New `GET /knowledge-bases/{knowledgeBaseId}/documents/{documentId}` (`getDocument`) and `DELETE /knowledge-bases/{knowledgeBaseId}/documents/{documentId}` (`deleteDocument`) operations.
  - New scopes `knowledge-base:documents:read` and `knowledge-base:documents:delete`.
  - `uploadDocument` 201 response now returns a `Document` resource and a `Location` header (see Breaking changes above).
- Documented the partial-update semantics of the PUT update operations `updateKnowledgeBase` and `updateTool` (issue [#50](https://github.com/camaraproject/ModelAsAService/issues/50)). The operation and `*UpdateRequest` schema descriptions now state explicitly that omitted fields are left unchanged (not cleared), that providing a field replaces its stored value, and that at least one updatable field MUST be provided. For `updateTool`, the `headers` field (`writeOnly`, issue #41) behaviour is also clarified: providing `headers` replaces the stored headers as a whole, while omitting `headers` preserves the previously stored headers (so an API consumer can update other fields without re-supplying credentials). This is a documentation-only change; the request/response structure and HTTP method (PUT) are unchanged. CAMARA API Design Guide §5.7.2 permits either `PUT` or `PATCH` for update operations, so `PUT` with documented partial-update semantics is retained.

### Changed
- API-specific error codes renamed to the `KNOWLEDGE_BASE.<SPECIFIC_CODE>` format defined in the CAMARA API Design Guide. This is a breaking change (see Breaking changes above). Renamed codes: `TOOL.INVALID_INPUT` -> `KNOWLEDGE_BASE.TOOL_INVALID_INPUT`, `TOOL.DISABLED` -> `KNOWLEDGE_BASE.TOOL_DISABLED`, `TOOL.EXECUTION_FAILED` -> `KNOWLEDGE_BASE.TOOL_EXECUTION_FAILED`, `TOOL.TIMEOUT` -> `KNOWLEDGE_BASE.TOOL_TIMEOUT` (issue [#38](https://github.com/camaraproject/ModelAsAService/issues/38)).
- The `headers` field of a tool is now `writeOnly: true`. This is a breaking change (see Breaking changes above). `createTool` and `updateTool` still accept the field; `getTool` and `listTools` no longer return it (issue [#41](https://github.com/camaraproject/ModelAsAService/issues/41)).
- The `headers` field example corrected from the forbidden `Authorization: Bearer {{token}}` (self-contradictory with the reserved-header list) to a non-credential example `Accept-Language: en-US`, so the example no longer presupposes that credentials belong in `headers` (issue [#42](https://github.com/camaraproject/ModelAsAService/issues/42)).
- `callTool` upstream response behaviour unified to the HTTP 200 envelope (issue [#44](https://github.com/camaraproject/ModelAsAService/issues/44)). This is a breaking change (see Breaking changes above). The `429` response was removed; upstream rate-limit and upstream failures are reported via the 200 `ToolCallResponse` envelope (`success=false`, `statusCode`, `contextCode`). The `500` response is retained only for platform-internal errors. The operation description's Response Characteristics clarify this.
- Removed `KNOWLEDGE_BASE.TOOL_INVALID_INPUT` and `KNOWLEDGE_BASE.TOOL_DISABLED` from the `ToolCallResponse.contextCode` enum. This is a breaking change (see Breaking changes above). These conditions are now reported exclusively via HTTP 422 `ToolInvalidInput422` (pre-invocation checks); `contextCode` is reserved for upstream invocation outcomes (issue [#45](https://github.com/camaraproject/ModelAsAService/issues/45)).
- Marked `items` and `pagination` as `required` in the `listKnowledgeBases` and `listTools` 200 response schemas, per CAMARA API Design Guide §4.1.3 which states that both MUST always be present in a paginated response body (issue [#47](https://github.com/camaraproject/ModelAsAService/issues/47)). This is not a breaking change: the response structure is unchanged, only the contract is made explicit. (Note: the `perPage` query parameter description in `code/common/CAMARA_common.yaml` reads "Number of subscriptions to return per page", which is a Commonalities-owned `cache-common` file that this repository must not modify; that wording originates from Commonalities r4.3 and is to be raised upstream.)
- All CAMARA common components (`securitySchemes.openId`, `x-correlator` parameter/header, `page`/`perPage` parameters, `ErrorInfo` schema, `DateTime` schema, `Pagination` schema, and the `Generic4xx`/`Generic5xx` response objects) are now referenced via external `$ref` to `code/common/CAMARA_common.yaml` instead of being copied inline into each API definition (issue [#37](https://github.com/camaraproject/ModelAsAService/issues/37)). This aligns with the Commonalities `cache-common` governance: the common file is owned by the Commonalities Working Group and must be byte-identical to the upstream release; the API repository only `$ref`s it. Test definitions reference the same components via local `$ref` (e.g. `#/components/schemas/Pagination`), matching the local references that result from the release bundling process. No public API surface change.

### Fixed
- Removed `additionalProperties: false` from the `allOf` inline branch of `ToolCreateRequest` and `ToolUpdateRequest`. In OpenAPI 3.0, `additionalProperties` does not propagate through `allOf`, so a `false` value on a branch with no own properties rejected every property (including required `name`/`url`), making the request schemas unsatisfiable for strict validators. Request body strictness for these composed schemas is now enforced by the `request-body-strictness` rule in `info.description`, as required by CAMARA API Design Guide §2.3 (issue [#43](https://github.com/camaraproject/ModelAsAService/issues/43)).

### Removed

* N/A

## qa-assistant-manage 0.2.0-rc.1

**qa-assistant-manage 0.2.0-rc.1 is a release-candidate version of this API.**

Changes documented below are compared to version 0.1.0.

- API definition **with inline documentation**:
  - [View it on ReDoc](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/ModelAsAService/r2.1/code/API_definitions/qa-assistant-manage.yaml&nocors)
  - [View it on Swagger Editor](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/ModelAsAService/r2.1/code/API_definitions/qa-assistant-manage.yaml)
  - OpenAPI [YAML spec file](https://github.com/camaraproject/ModelAsAService/blob/r2.1/code/API_definitions/qa-assistant-manage.yaml)

### Breaking changes
- The `createAssistant` 201 response and the `updateAssistant` 200 response no longer return the `AssistantResponse` envelope `{ success, assistantId, message }`; they now return the created/updated `Assistant` resource itself (issue [#49](https://github.com/camaraproject/ModelAsAService/issues/49)). This aligns `qa-assistant-manage` with `knowledge-base`, where `createKnowledgeBase` / `createTool` / `updateTool` already return the resource itself. The `AssistantResponse` schema is removed. API consumers that read the envelope's `success` / `assistantId` / `message` fields MUST update to read the corresponding fields on the `Assistant` resource (`assistantId` is now a property of `Assistant`; the `success` boolean and `message` string are no longer returned).
- The `largeModelParameters` schema is flattened: the intermediate `parameters` object is removed and `model`, `temperature`, `maxTokens` (and `topP`) are now direct properties of `largeModelParameters` (issue [#52](https://github.com/camaraproject/ModelAsAService/issues/52)). API consumers that referenced `largeModelParameters.parameters.temperature` (etc.) MUST update to `largeModelParameters.temperature`. The change applies to `AssistantCreateRequest`, `AssistantUpdateRequest`, and `Assistant` consistently.

### Added

- Documented the intended tool usage model in the `toolIds` field description: tools associated with an assistant via `toolIds` may be invoked automatically by the assistant's LLM during answer generation (via `queryAssistant` on the `qa-assistant-service` API), turning the assistant into an agent that can take actions to ground or enrich its answers (issue [#39](https://github.com/camaraproject/ModelAsAService/issues/39)).
- Documented the partial-update semantics of the PUT `updateAssistant` operation (issue [#50](https://github.com/camaraproject/ModelAsAService/issues/50)). The operation and `AssistantUpdateRequest` schema descriptions now state explicitly that omitted fields are left unchanged (not cleared), that providing a field replaces its stored value, and that at least one updatable field MUST be provided. Merge rules for nested objects are also clarified: `largeModelParameters` is replaced as a whole when provided (nested merge is NOT supported - to change a single parameter the API consumer MUST provide the complete `largeModelParameters` object), and `toolIds` is replaced as a whole when provided (overwritten, not appended to). This is a documentation-only change; the request/response structure and HTTP method (PUT) are unchanged. CAMARA API Design Guide §5.7.2 permits either `PUT` or `PATCH` for update operations, so `PUT` with documented partial-update semantics is retained.
- Documented that the hard bounds on `largeModelParameters.temperature` (max 1) and `maxTokens` (max 128000) are reference defaults and that the provider MAY adjust them to match the supported range of the underlying LLM backend (issue [#52](https://github.com/camaraproject/ModelAsAService/issues/52)). The provider's actual enforced range MUST be documented in the API provider's documentation. The `gpt-4` example is retained as an example and is not a constraint.

### Changed
- Marked `items` and `pagination` as `required` in the `listAssistants` 200 response schema, per CAMARA API Design Guide §4.1.3 which states that both MUST always be present in a paginated response body (issue [#47](https://github.com/camaraproject/ModelAsAService/issues/47)). This is not a breaking change: the response structure is unchanged, only the contract is made explicit.
- All CAMARA common components (`securitySchemes.openId`, `x-correlator` parameter/header, `page`/`perPage` parameters, `ErrorInfo` schema, `DateTime` schema, `Pagination` schema, and the `Generic4xx`/`Generic5xx` response objects) are now referenced via external `$ref` to `code/common/CAMARA_common.yaml` instead of being copied inline (issue [#37](https://github.com/camaraproject/ModelAsAService/issues/37)). No public API surface change.
- `createAssistant` and `updateAssistant` now return the created/updated `Assistant` resource instead of the `AssistantResponse` envelope. This is a breaking change (see Breaking changes above). The `AssistantResponse` schema is removed (issue [#49](https://github.com/camaraproject/ModelAsAService/issues/49)).
- Defined a single behaviour for what happens to an assistant's `toolIds` when a referenced tool is deleted (issue [#51](https://github.com/camaraproject/ModelAsAService/issues/51)). The previous spec allowed the server to either retain the dangling reference (returning `422 KNOWLEDGE_BASE.TOOL_NOT_FOUND` on read) or silently drop it. The spec now mandates the latter (prune): when a tool is deleted via `DELETE /knowledge-bases/{id}/tools/{toolId}` on the `knowledge-base` API, the server MUST silently drop the deleted tool's ID from any assistant `toolIds` that referenced it, on the next read (`getAssistant` / `listAssistants`); reads do NOT return `422` for a pruned tool. This makes the cross-API contract dependable across implementations: the `toolIds` array always reflects the currently existing tools. The write-time validation (`422 KNOWLEDGE_BASE.TOOL_NOT_FOUND` / `KNOWLEDGE_BASE.TOOL_CROSS_KB` on `createAssistant` / `updateAssistant`) is unchanged: a tool ID supplied at write time MUST still exist at that moment. The `deleteTool` operation description on the `knowledge-base` API documents the cross-API effect.

### Fixed

* N/A

### Removed

* N/A

## qa-assistant-service 0.2.0-rc.1

**qa-assistant-service 0.2.0-rc.1 is a release-candidate version of this API.**

Changes documented below are compared to version 0.1.0.

- API definition **with inline documentation**:
  - [View it on ReDoc](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/ModelAsAService/r2.1/code/API_definitions/qa-assistant-service.yaml&nocors)
  - [View it on Swagger Editor](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/ModelAsAService/r2.1/code/API_definitions/qa-assistant-service.yaml)
  - OpenAPI [YAML spec file](https://github.com/camaraproject/ModelAsAService/blob/r2.1/code/API_definitions/qa-assistant-service.yaml)

### Breaking changes

* N/A

### Added
- Documented the intended tool usage model in the `queryAssistant` operation description: when the assistant has tools associated via `toolIds` (configured through `qa-assistant-manage`), the platform's LLM may invoke those tools automatically during answer generation; tool invocation details are not surfaced in the `QueryResponse` in this API version, and tool failures during generation are reflected in the `finished` status rather than HTTP error codes (issue [#39](https://github.com/camaraproject/ModelAsAService/issues/39)).
- Added a security note to the `queryAssistant` operation description: LLM-initiated tool invocations cause the API provider's server to send outbound HTTP requests to consumer-registered tool URLs, and the SSRF protections the provider MUST enforce for such outbound calls are documented in the "Security considerations" section of the `knowledge-base` API (issue [#40](https://github.com/camaraproject/ModelAsAService/issues/40)).
- Documented the relationship between `success` and `finished` in `QueryResponse`, per CAMARA API Design Guide §3.1.2 (issue [#47](https://github.com/camaraproject/ModelAsAService/issues/47)). The schema description now includes the full mapping table (`STOP`/`LENGTH` -> `success=true`; `ERROR`/`FILTER` -> `success=false`), and the `success`, `finished` and `answerText` field descriptions clarify that the two outcome fields MUST be consistent and that `answerText` is empty or a short diagnostic string when `success=false`. The `queryAssistant` operation description's Response Characteristics section also summarises this relationship. The HTTP status of `queryAssistant` remains `200` for every value of `finished`; `success=false` does not change the HTTP status.
- All CAMARA common components (`securitySchemes.openId`, `x-correlator` parameter/header, `page`/`perPage` parameters, `ErrorInfo` schema, `DateTime` schema, `Pagination` schema, and the `Generic4xx`/`Generic5xx` response objects) are now referenced via external `$ref` to `code/common/CAMARA_common.yaml` instead of being copied inline (issue [#37](https://github.com/camaraproject/ModelAsAService/issues/37)). No public API surface change.

### Changed

- Clarified in the `queryAssistant` operation description that only documents with indexing `status = READY` in the associated knowledge bases participate in answer generation (issue [#48](https://github.com/camaraproject/ModelAsAService/issues/48)). Documents in `PROCESSING` or `FAILED` status are excluded. This is a documentation-only change; the request/response structure is unchanged.

### Fixed

* N/A

### Removed

* N/A

**Full Changelog**: https://github.com/camaraproject/ModelAsAService/compare/r1.2...r2.1

