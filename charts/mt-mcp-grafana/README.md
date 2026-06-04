# mt-mcp-grafana

![Version: 0.9.0](https://img.shields.io/badge/Version-0.9.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)

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
| backendMetrics | object | `{"enabled":true,"path":"/metrics","port":9090,"serviceMonitor":{"enabled":false,"interval":"30s","labels":{},"metricRelabelings":[],"namespace":"","relabelings":[],"scrapeTimeout":"10s"}}` | Metrics for the managed mcp-grafana backend pods. The unmodified mcp-grafana image serves Prometheus metrics on a SEPARATE listener (--metrics --metrics-address :<port>), kept off the :8000 MCP data plane to avoid a port clash. Backends emit the same OTel mcp_server_* series as the proxy; they do not collide because each scrape target carries distinct job/service/pod labels, and the backend ServiceMonitor adds the per-instance mcp_instance label. Only applies to managed backends (externalUrl backends are scraped by whoever runs them). |
| backendMetrics.enabled | bool | `true` | Enable the metrics listener on managed mcp-grafana backends |
| backendMetrics.path | string | `"/metrics"` | Path the backend metrics endpoint is served on (mcp-grafana uses /metrics) |
| backendMetrics.port | int | `9090` | Port the backend serves Prometheus metrics on (separate from MCP :8000) |
| backendMetrics.serviceMonitor | object | `{"enabled":false,"interval":"30s","labels":{},"metricRelabelings":[],"namespace":"","relabelings":[],"scrapeTimeout":"10s"}` | Create a ServiceMonitor for the backend metrics (requires the Operator) |
| backendMetrics.serviceMonitor.enabled | bool | `false` | Enable backend ServiceMonitor creation |
| backendMetrics.serviceMonitor.interval | string | `"30s"` | Scrape interval |
| backendMetrics.serviceMonitor.labels | object | `{}` | Additional labels for ServiceMonitor discovery |
| backendMetrics.serviceMonitor.metricRelabelings | list | `[]` | Metric relabeling rules applied after scraping |
| backendMetrics.serviceMonitor.namespace | string | `""` | Namespace for the ServiceMonitor (defaults to release namespace) |
| backendMetrics.serviceMonitor.relabelings | list | `[]` | Relabeling rules applied before scraping |
| backendMetrics.serviceMonitor.scrapeTimeout | string | `"10s"` | Scrape timeout |
| backends | list | `[{"args":["--disable-sift","--disable-oncall","--disable-incident"],"grafanaUrl":"https://grafana.company.com/team-ab","headers":{},"name":"grafana-ab","tenants":[{"groups":["team-a"],"headers":{},"id":"team-a"},{"groups":["team-b"],"headers":{"X-Grafana-Org-Id":"2"},"id":"team-b"}],"tokenSecret":{"create":true,"key":"token","name":"grafana-ab-token-secret","value":"glsa_my-service-account-token-ab"}},{"grafanaUrl":"https://grafana.company.com/team-c","headers":{},"name":"grafana-c","tenants":[{"groups":["team-c"],"headers":{},"id":"team-c"}],"tokenSecret":{"create":true,"key":"token","name":"grafana-c-token-secret","value":"glsa_my-service-account-token-c"}}]` | mcp-grafana backends. Each entry is either a MANAGED backend (the chart deploys an mcp-grafana pod for it) or an EXTERNAL backend (an already-running mcp-grafana at a URL you provide). The proxy routes to both the same way.  Managed (default): the chart deploys an mcp-grafana pod + Service and wires the proxy to it via in-cluster DNS. Set grafanaUrl + tokenSecret.  External: set externalUrl to the pre-existing mcp-grafana endpoint URL. The chart will NOT deploy a pod/service; the proxy routes directly to that URL. The service account token must still be provided (via tokenSecret) so the proxy can inject it as the upstream Authorization header. SECURITY: external mcp-grafana has no inbound auth. The URL must be network-secured (VPN, mTLS, IP allowlist) — anyone who can reach it bypasses the proxy's JWT verification.  Model: groups authorize, tenant selects, backend executes. A tenant id is what list_grafana_instances advertises and what the agent targets via the `tenant` tool argument. The caller's JWT groups must intersect a tenant's groups to use it. |
| backends[0] | object | `{"args":["--disable-sift","--disable-oncall","--disable-incident"],"grafanaUrl":"https://grafana.company.com/team-ab","headers":{},"name":"grafana-ab","tenants":[{"groups":["team-a"],"headers":{},"id":"team-a"},{"groups":["team-b"],"headers":{"X-Grafana-Org-Id":"2"},"id":"team-b"}],"tokenSecret":{"create":true,"key":"token","name":"grafana-ab-token-secret","value":"glsa_my-service-account-token-ab"}}` | Example: managed backend (chart deploys mcp-grafana pod + service) |
| backends[0].args | list | `["--disable-sift","--disable-oncall","--disable-incident"]` | Optional CLI arguments passed to the mcp-grafana container |
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
| image.repository | string | `"ghcr.io/loafoe/mt-mcp-grafana"` | Docker registry repository for mt-mcp-grafana |
| image.tag | string | `"v0.1.0"` | Image tag to deploy. Matches the upstream git tag / published OCI tag (the build workflow publishes ghcr.io/loafoe/mt-mcp-grafana:<git-tag>). |
| metrics | object | `{"enabled":true,"path":"/metrics","port":9090}` | Observability. The proxy exposes Prometheus metrics on a SEPARATE listener (isolated from the /mcp data plane), and emits OTLP traces driven by the standard OTEL_* environment variables. |
| metrics.enabled | bool | `true` | Enable the metrics listener (adds a container/service port + config block) |
| metrics.path | string | `"/metrics"` | Path the metrics endpoint is served on |
| metrics.port | int | `9090` | Port the proxy serves Prometheus metrics on inside the container |
| nameOverride | string | `""` | Override the name of the chart |
| nodeSelector | object | `{}` | Node selectors for pod scheduling |
| replicaCount | int | `1` | Number of proxy replicas (sessions are in-memory; use sticky routing with >1) |
| resources | object | `{}` | Pod resource requests and limits |
| server.path | string | `"/mcp"` | The exposed MCP endpoint path |
| server.port | int | `8080` | The port the proxy binary listens on inside the container |
| service.port | int | `8080` | Service port |
| service.type | string | `"ClusterIP"` | Kubernetes Service type for exposing the proxy |
| serviceMonitor | object | `{"enabled":false,"interval":"30s","labels":{},"metricRelabelings":[],"namespace":"","relabelings":[],"scrapeTimeout":"10s","targetLabels":[]}` | ServiceMonitor for Prometheus Operator scraping of the proxy metrics port |
| serviceMonitor.enabled | bool | `false` | Enable ServiceMonitor creation (requires the Prometheus Operator CRDs) |
| serviceMonitor.interval | string | `"30s"` | Scrape interval |
| serviceMonitor.labels | object | `{}` | Additional labels for ServiceMonitor discovery (e.g. release: kube-prometheus-stack) |
| serviceMonitor.metricRelabelings | list | `[]` | Metric relabeling rules applied after scraping |
| serviceMonitor.namespace | string | `""` | Namespace for the ServiceMonitor (defaults to release namespace) |
| serviceMonitor.relabelings | list | `[]` | Relabeling rules applied before scraping |
| serviceMonitor.scrapeTimeout | string | `"10s"` | Scrape timeout |
| serviceMonitor.targetLabels | list | `[]` | Target labels to transfer from the Service to scraped metrics |
| tolerations | list | `[]` | Pod tolerations |
| tracing | object | `{"enableOnBackends":false,"enabled":false,"endpoint":"http://otel-collector:4317","extraEnv":{},"serviceName":"mt-mcp-grafana"}` | OpenTelemetry tracing. Tracing is enabled inside the proxy only when OTEL_EXPORTER_OTLP_ENDPOINT is set. The same vars can be set on the managed mcp-grafana backends so downstream traces correlate end-to-end with the proxy's (the proxy always injects W3C traceparent on backend calls). |
| tracing.enableOnBackends | bool | `false` | Also set OTEL_* env on the managed mcp-grafana backend pods so they join the proxy's trace. OTEL_SERVICE_NAME is derived per backend (mcp-grafana-<name>). |
| tracing.enabled | bool | `false` | Enable tracing by setting OTEL_* env on the proxy (and backends) |
| tracing.endpoint | string | `"http://otel-collector:4317"` | OTLP gRPC collector endpoint (sets OTEL_EXPORTER_OTLP_ENDPOINT) |
| tracing.extraEnv | object | `{}` | Additional raw OTEL_* env vars to set on the proxy container |
| tracing.serviceName | string | `"mt-mcp-grafana"` | Service name reported by the proxy (sets OTEL_SERVICE_NAME) |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
