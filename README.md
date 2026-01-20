<a href="https://github.com/camaraproject/ModelAsAService/commits/" title="Last Commit"><img src="https://img.shields.io/github/last-commit/camaraproject/ModelAsAService?style=plastic"></a>
<a href="https://github.com/camaraproject/ModelAsAService/issues" title="Open Issues"><img src="https://img.shields.io/github/issues/camaraproject/ModelAsAService?style=plastic"></a>
<a href="https://github.com/camaraproject/ModelAsAService/pulls" title="Open Pull Requests"><img src="https://img.shields.io/github/issues-pr/camaraproject/ModelAsAService?style=plastic"></a>
<a href="https://github.com/camaraproject/ModelAsAService/graphs/contributors" title="Contributors"><img src="https://img.shields.io/github/contributors/camaraproject/ModelAsAService?style=plastic"></a>
<a href="https://github.com/camaraproject/ModelAsAService" title="Repo Size"><img src="https://img.shields.io/github/repo-size/camaraproject/ModelAsAService?style=plastic"></a>
<a href="https://github.com/camaraproject/ModelAsAService/blob/main/LICENSE" title="License"><img src="https://img.shields.io/badge/License-Apache%202.0-green.svg?style=plastic"></a>
<a href="https://github.com/camaraproject/ModelAsAService/releases/latest" title="Latest Release"><img src="https://img.shields.io/github/release/camaraproject/ModelAsAService?style=plastic"></a>
<a href="https://github.com/camaraproject/Governance/blob/main/ProjectStructureAndRoles.md" title="Sandbox API Repository"><img src="https://img.shields.io/badge/Sandbox%20API%20Repository-yellow?style=plastic"></a>

# ModelAsAService

Sandbox API Repository to describe, develop, document, and test the ModelAsAService Service API(s). The repository does not yet belong to a CAMARA Sub Project.

* API Repository [wiki page](https://lf-camaraproject.atlassian.net/wiki/x/_4AjAw)

## Scope

* Service APIs “ModelAsAService” (see APIBacklog.md)
* MaaS (Model as a Services) refers to the packaging of AI models and their associated capabilities into reusable services, enabling users to quickly and efficiently build, deploy, monitor, and invoke models without the need to develop and maintain underlying foundational capabilities.
* The API provides the API consumer with the ability to:  
  * build and manage personalized Knowledge Bases (knowledge-base)
  * quickly construct unique Q&A Assistant applications (qa-assistant-manage)
  * provide Q&A services to the users of the application (qa-assistant-service)
  * NOTE: more model services to be added.
* Describe, develop, document, and test the APIs
* Started: November 2024

## Release Information

* Note: Please be aware that the project will have frequent updates to the main branch. There are no compatibility guarantees associated with code in any branch, including main, until a new release is created. For example, changes may be reverted before a release is created. For best results, use the latest public release.

* **NEW** Public release [r1.2](https://github.com/camaraproject/ModelAsAService/releases/tag/r1.2) is available, with the following API:
    * knowledge-base: [YAML spec file](https://github.com/camaraproject/ModelAsAService/blob/r1.2/code/API_definitions/knowledge-base.yaml)[View it on ReDoc](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/ModelAsAService/r1.2/code/API_definitions/knowledge-base.yaml&nocors)[View it on Swagger Editor](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/ModelAsAService/r1.2/code/API_definitions/knowledge-base.yaml)
    * qa-assistant-manage: [YAML spec file](https://github.com/camaraproject/ModelAsAService/blob/r1.2/code/API_definitions/qa-assistant-manage.yaml)[View it on ReDoc](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/ModelAsAService/r1.2/code/API_definitions/qa-assistant-manage.yaml&nocors)[View it on Swagger Editor](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/ModelAsAService/r1.2/code/API_definitions/qa-assistant-manage.yaml)
    * qa-assistant-service: [YAML spec file](https://github.com/camaraproject/ModelAsAService/blob/r1.2/code/API_definitions/qa-assistant-service.yaml)[View it on ReDoc](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/ModelAsAService/r1.2/code/API_definitions/qa-assistant-service.yaml&nocors)[View it on Swagger Editor](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/ModelAsAService/r1.2/code/API_definitions/qa-assistant-service.yaml)

<!-- Optional: an explicit listing of the latest (pre-)release with additional information, e.g. links to the API definitions -->
<!-- In addition use/uncomment one or multiple the following alternative options when becoming applicable -->
* Pre-releases of this sub project are available in https://github.com/camaraproject/ModelAsAService/releases
<!-- The latest public release is available here: https://github.com/camaraproject/ModelAsAService/releases/latest -->
* For changes see [CHANGELOG.md](https://github.com/camaraproject/ModelAsAService/blob/main/CHANGELOG.md)

## Contributing

* Meetings are held virtually
    * Schedule: Bi-weekly (odd weeks), Tuesday, 09:00 UTC (11:00 UTC+2, 17:00 UTC+8)
    * [Join](https://teams.live.com/meet/9374614741908?p=QFhUf7b0SHZRdXSfA6)
    * Minutes: Access [meeting minutes](https://lf-camaraproject.atlassian.net/l/cp/GpKaVSqC)
* Mailing List
    * Subscribe / Unsubscribe to the mailing list of this Sub Project <https://lists.camaraproject.org/g/sp-maas>.
    * A message to the community of this Sub Project can be sent using <sp-maas@lists.camaraproject.org>.
