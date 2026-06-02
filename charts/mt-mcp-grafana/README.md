# mt-mcp-grafana

![Version: 0.3.0](https://img.shields.io/badge/Version-0.3.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)

A multi-tenant proxy that aggregates and secures multiple mcp-grafana backend instances speaking the MCP streamable-HTTP transport.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Pod affinity rules |
| auth | object | `{"audience":"mcp-grafana","groupsClaim":"groups","issuer":"https://issuer.company.com","jwksUrl":"","mode":"jwks"}` | Authentication settings for incoming LLM/client JWTs |
| auth.audience | string | `"mcp-grafana"` | Expected JWT audience (aud claim) |
| auth.groupsClaim | string | `"groups"` | Path to the claim in the JWT holding user groups |
| auth.issuer | string | `"https://issuer.company.com"` | Expected JWT issuer (iss claim) |
| auth.jwksUrl | string | `""` | Optional explicit JWKS URL (if omitted, discovered via OIDC metadata) |
| auth.mode | string | `"jwks"` | JWT verification mode: jwks | static | insecure |
| backends | list | `[{"grafanaUrl":"https://grafana.company.com/team-ab","headers":{},"name":"grafana-ab","tenants":[{"groups":["team-a"],"headers":{},"id":"team-a"},{"groups":["team-b"],"headers":{"X-Grafana-Org-Id":"2"},"id":"team-b"}],"tokenSecret":{"create":true,"key":"token","name":"grafana-ab-token-secret","value":"glsa_my-service-account-token-ab"}},{"grafanaUrl":"https://grafana.company.com/team-c","headers":{},"name":"grafana-c","tenants":[{"groups":["team-c"],"headers":{},"id":"team-c"}],"tokenSecret":{"create":true,"key":"token","name":"grafana-c-token-secret","value":"glsa_my-service-account-token-c"}}]` | mcp-grafana backends. Each entry is either a MANAGED backend (the chart deploys an mcp-grafana pod for it) or an EXTERNAL backend (an already-running mcp-grafana at a URL you provide). The proxy routes to both the same way.  Managed (default): the chart deploys an mcp-grafana pod + Service and wires the proxy to it via in-cluster DNS. Set grafanaUrl + tokenSecret.  External: set externalUrl to the pre-existing mcp-grafana endpoint URL. The chart will NOT deploy a pod/service; the proxy routes directly to that URL. The service account token must still be provided (via tokenSecret) so the proxy can inject it as the upstream Authorization header. SECURITY: external mcp-grafana has no inbound auth. The URL must be network-secured (VPN, mTLS, IP allowlist) — anyone who can reach it bypasses the proxy's JWT verification.  Model: groups authorize, tenant selects, backend executes. A tenant id is what list_grafana_instances advertises and what the agent targets via the `tenant` tool argument. The caller's JWT groups must intersect a tenant's groups to use it. |
| backends[0] | object | `{"grafanaUrl":"https://grafana.company.com/team-ab","headers":{},"name":"grafana-ab","tenants":[{"groups":["team-a"],"headers":{},"id":"team-a"},{"groups":["team-b"],"headers":{"X-Grafana-Org-Id":"2"},"id":"team-b"}],"tokenSecret":{"create":true,"key":"token","name":"grafana-ab-token-secret","value":"glsa_my-service-account-token-ab"}}` | Example: managed backend (chart deploys mcp-grafana pod + service) |
| backends[0].grafanaUrl | string | `"https://grafana.company.com/team-ab"` | Target Grafana stack URL for the managed mcp-grafana instance |
| backends[0].headers | object | `{}` | Optional per-backend headers sent toward this mcp-grafana instance |
| backends[0].name | string | `"grafana-ab"` | Internal/ops name for this backend (logging, must be unique) |
| backends[0].tenants | list | `[{"groups":["team-a"],"headers":{},"id":"team-a"},{"groups":["team-b"],"headers":{"X-Grafana-Org-Id":"2"},"id":"team-b"}]` | Tenants served by this backend. Each tenant is a selectable routing unit: its id is advertised to the agent, and its groups determine who can select it. |
| backends[0].tenants[0].groups | list | `["team-a"]` | JWT groups authorized to select this tenant |
| backends[0].tenants[0].headers | object | `{}` | Optional per-tenant headers (merge over backend headers) |
| backends[0].tenants[0].id | string | `"team-a"` | Globally unique tenant id (the routing key) |
| backends[0].tokenSecret | object | `{"create":true,"key":"token","name":"grafana-ab-token-secret","value":"glsa_my-service-account-token-ab"}` | Service account token secret configuration |
| backends[0].tokenSecret.create | bool | `true` | Whether this chart should create the Secret inline |
| backends[0].tokenSecret.key | string | `"token"` | Key in the Secret holding the token |
| backends[0].tokenSecret.name | string | `"grafana-ab-token-secret"` | Kubernetes Secret name |
| backends[0].tokenSecret.value | string | `"glsa_my-service-account-token-ab"` | Raw service account token (only used if tokenSecret.create is true) |
| backends[1] | object | `{"grafanaUrl":"https://grafana.company.com/team-c","headers":{},"name":"grafana-c","tenants":[{"groups":["team-c"],"headers":{},"id":"team-c"}],"tokenSecret":{"create":true,"key":"token","name":"grafana-c-token-secret","value":"glsa_my-service-account-token-c"}}` | Example: another managed backend |
| fullnameOverride | string | `""` | Override the fully qualified name of the chart |
| image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| image.repository | string | `"andy/mt-mcp-grafana"` | Docker registry repository for mt-mcp-grafana |
| image.tag | string | `""` | Overrides the image tag (defaults to the chart appVersion) |
| nameOverride | string | `""` | Override the name of the chart |
| nodeSelector | object | `{}` | Node selectors for pod scheduling |
| replicaCount | int | `1` | Number of proxy replicas (sessions are in-memory; use sticky routing with >1) |
| resources | object | `{}` | Pod resource requests and limits |
| server.path | string | `"/mcp"` | The exposed MCP endpoint path |
| server.port | int | `8080` | The port the proxy binary listens on inside the container |
| service.port | int | `8080` | Service port |
| service.type | string | `"ClusterIP"` | Kubernetes Service type for exposing the proxy |
| tolerations | list | `[]` | Pod tolerations |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
