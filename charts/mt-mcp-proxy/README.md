# mt-mcp-proxy

![Version: 0.4.2](https://img.shields.io/badge/Version-0.4.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.3.3](https://img.shields.io/badge/AppVersion-0.3.3-informational?style=flat-square)

A generic multi-tenant JWT/OIDC auth gateway that fronts any streamable-HTTP MCP server (e.g. github-mcp-server, mcp-grafana) with group-based tenant routing and per-tenant credential injection.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity |
| auth | object | `{"additionalAudiences":[],"audience":"mt-mcp-proxy","groupsClaim":"groups","issuer":"https://issuer.company.com","jwksUrl":"","mode":"jwks","publicKeyPemFile":""}` | Authentication for incoming client/LLM JWTs |
| auth.additionalAudiences | list | `[]` | Extra acceptable audiences beyond `audience` |
| auth.audience | string | `"mt-mcp-proxy"` | Expected audience (aud) |
| auth.groupsClaim | string | `"groups"` | JWT claim holding the caller's groups |
| auth.issuer | string | `"https://issuer.company.com"` | Expected issuer (iss) |
| auth.jwksUrl | string | `""` | Optional explicit JWKS URL (if omitted, discovered via OIDC metadata) |
| auth.mode | string | `"jwks"` | JWT verification mode: jwks | static | insecure |
| auth.publicKeyPemFile | string | `""` | Static mode credentials (only when auth.mode is "static") hmacSecret: "my-hmac-shared-key" publicKeyPemFile mounted at /etc/mt-mcp-proxy/keys/public.pem if set |
| backendMetrics | object | `{"enabled":false,"path":"/metrics","port":9090,"serviceMonitor":{"enabled":false,"interval":"30s","labels":{},"metricRelabelings":[],"namespace":"","relabelings":[],"scrapeTimeout":"10s"}}` | Metrics for MANAGED backend pods (external backends are scraped by whoever runs them). Applies uniformly to every managed backend in the `backends` list — matches mt-mcp-grafana's single global block; no evidence different backends need different metrics ports/paths. |
| backendMetrics.enabled | bool | `false` | Enable a metrics container port + env on managed backends |
| backendMetrics.path | string | `"/metrics"` | Path managed backends serve metrics on |
| backendMetrics.port | int | `9090` | Port managed backends serve Prometheus metrics on |
| backendMetrics.serviceMonitor.enabled | bool | `false` | Enable ServiceMonitor creation for managed-backend metrics |
| backendMetrics.serviceMonitor.interval | string | `"30s"` | Scrape interval |
| backendMetrics.serviceMonitor.labels | object | `{}` | Additional labels for ServiceMonitor discovery |
| backendMetrics.serviceMonitor.metricRelabelings | list | `[]` | Metric relabeling rules applied after scraping |
| backendMetrics.serviceMonitor.namespace | string | `""` | Namespace for the ServiceMonitor (defaults to release namespace) |
| backendMetrics.serviceMonitor.relabelings | list | `[]` | Relabeling rules applied before scraping |
| backendMetrics.serviceMonitor.scrapeTimeout | string | `"10s"` | Scrape timeout |
| backends | list | `[{"credentialHeader":"Authorization","credentialScheme":"Bearer","credentialSecret":{"create":false,"key":"token","name":"","value":""},"externalUrl":"","headers":{},"managed":{"args":["http"],"command":[],"configFile":{"content":"","enabled":false,"fileName":"config.yaml","mountPath":"/etc/mt-mcp-proxy/backend-config"},"credentialEnvVar":"","enabled":true,"env":{},"image":{"pullPolicy":"IfNotPresent","repository":"ghcr.io/github/github-mcp-server","tag":"latest"},"path":"/","port":8082,"resources":{},"secretEnv":[]},"name":"github","protocolVersion":"","tenants":[{"credentialSecret":{"create":false,"key":"token","name":"github-pat-platform","value":""},"groups":["platform-eng"],"headers":{"X-MCP-Toolsets":"repos,issues,pull_requests"},"id":"team-platform"},{"credentialSecret":{"create":false,"key":"token","name":"github-pat-data","value":""},"groups":["data-eng"],"headers":{"X-MCP-Readonly":"true"},"id":"team-data"}]}]` | The downstream MCP backends this deployment fronts. Each entry is either MANAGED (the chart deploys a Deployment+Service for it) or EXTERNAL (you point at an already-running streamable-HTTP MCP server). One deployment can front multiple backends of the same product (e.g. several Grafana instances) or, by convention, a single product. |
| backends[0].credentialHeader | string | `"Authorization"` | How the credential is injected downstream. Defaults suit github-mcp-server (Authorization: Bearer <token>). For an API-key backend set e.g. credentialHeader: X-Api-Key and credentialScheme: "". |
| backends[0].credentialSecret | object | `{"create":false,"key":"token","name":"","value":""}` | Backend-level credential (optional). Used as the downstream token when a tenant of this backend does not supply its own credentialSecret (e.g. github: each tenant has its own PAT, so this is usually empty; a Grafana backend: one SA token shared by that backend's tenant(s), so this is set and per-tenant credentialSecret is omitted). Provided via a Secret so it never lands in the rendered ConfigMap. |
| backends[0].credentialSecret.create | bool | `false` | Have the chart create the Secret inline from `value` (dev/testing) |
| backends[0].credentialSecret.key | string | `"token"` | Key in the Secret |
| backends[0].credentialSecret.name | string | `""` | Secret name holding this backend's credential (empty = none) |
| backends[0].credentialSecret.value | string | `""` | Raw credential (only used when create is true) |
| backends[0].externalUrl | string | `""` | External backend URL (used only when managed.enabled is false), e.g. "http://github-mcp-server.example.svc:8082/". |
| backends[0].headers | object | `{}` | Optional static headers sent toward this backend on every request |
| backends[0].managed | object | `{"args":["http"],"command":[],"configFile":{"content":"","enabled":false,"fileName":"config.yaml","mountPath":"/etc/mt-mcp-proxy/backend-config"},"credentialEnvVar":"","enabled":true,"env":{},"image":{"pullPolicy":"IfNotPresent","repository":"ghcr.io/github/github-mcp-server","tag":"latest"},"path":"/","port":8082,"resources":{},"secretEnv":[]}` | Managed backend: when enabled, the chart deploys the downstream MCP server (a Deployment + Service) and wires the proxy to it via in-cluster DNS. When disabled, set `externalUrl` to a pre-existing streamable-HTTP MCP endpoint (the proxy routes directly to it; nothing is deployed). SECURITY: an external/managed backend has NO inbound auth of its own — it must be reachable only from the proxy (NetworkPolicy / cluster- internal), since anyone who can reach it bypasses the proxy's JWT verification. |
| backends[0].managed.command | list | `[]` | Command/args to launch the backend in streamable-HTTP mode. github-mcp-server: `http` serves MCP at / on :8082. |
| backends[0].managed.configFile | object | `{"content":"","enabled":false,"fileName":"config.yaml","mountPath":"/etc/mt-mcp-proxy/backend-config"}` | Optional file-based config for backends that require a config file rather than plain env vars (e.g. mcp-notifier's YAML webhook config). Renders a ConfigMap and mounts it read-only at `mountPath/fileName`. The file content may reference ${ENV_VAR} placeholders - Kubernetes does NOT expand these, the backend binary must (mcp-notifier does, via os.Expand against its own env). Combine with `env` above (for the file path env var, if the backend needs one) and `credentialEnvVar`/tenant `credentialSecret` (for the secret-backed values the file's placeholders resolve to). |
| backends[0].managed.credentialEnvVar | string | `""` | If this backend needs its OWN upstream credential injected as an env var (as opposed to the proxy injecting it as a header toward github-mcp-server), set the env var name the binary expects here, e.g. "GRAFANA_SERVICE_ACCOUNT_TOKEN" for grafana/mcp-grafana. The value comes from this backend's credentialSecret (below). Leave empty for backends like github-mcp-server that take no credential of their own (the proxy is the one authenticating to them). |
| backends[0].managed.enabled | bool | `true` | Deploy the downstream MCP server as part of this release |
| backends[0].managed.env | object | `{}` | Env vars for the backend container (e.g. GITHUB_HOST for GHES). Do NOT put per-tenant tokens here — those are injected per request by the proxy. |
| backends[0].managed.image.repository | string | `"ghcr.io/github/github-mcp-server"` | Downstream MCP server image (default: github-mcp-server) |
| backends[0].managed.path | string | `"/"` | Path this managed backend's MCP endpoint is served on. github-mcp-server (the default) serves at root; other backends (e.g. mcp-grafana) serve at a sub-path like "/mcp". Defaults to "/" (root) to preserve today's behavior for backends that don't set this. |
| backends[0].managed.port | int | `8082` | Container port the backend's MCP endpoint listens on |
| backends[0].managed.secretEnv | list | `[]` | Additional secret-backed env vars beyond the single credentialEnvVar/credentialSecret pair above, for backends that need more than one secret injected as an env var (e.g. mcp-notifier needs a Slack AND a Teams webhook URL). Each entry creates one env var sourced from an existing Secret - these secrets are NOT created by this chart, create them out-of-band. |
| backends[0].name | string | `"github"` | Internal/ops name (logging, DNS of the managed backend service). Must be unique across all entries in this list. |
| backends[0].protocolVersion | string | `""` | MCP revision spoken toward this backend. Defaults to "2025-03-26" (stateful: initialize handshake + Mcp-Session-Id). Set to "2026-07-28" for a backend that speaks the stateless revision (e.g. github-mcp-server http >= v1.12.2) — the proxy then skips initialize entirely. |
| backends[0].tenants | list | `[{"credentialSecret":{"create":false,"key":"token","name":"github-pat-platform","value":""},"groups":["platform-eng"],"headers":{"X-MCP-Toolsets":"repos,issues,pull_requests"},"id":"team-platform"},{"credentialSecret":{"create":false,"key":"token","name":"github-pat-data","value":""},"groups":["data-eng"],"headers":{"X-MCP-Readonly":"true"},"id":"team-data"}]` | Tenants this backend serves. Model: groups authorize, tenant selects, backend executes. Each tenant's id is advertised via list_instances and is the `tenant` tool-argument value; its groups gate access; its credential (if set) overrides the backend-level credential above for calls routed to this tenant. |
| backends[0].tenants[0].credentialSecret | object | `{"create":false,"key":"token","name":"github-pat-platform","value":""}` | Per-tenant credential override (optional). Omit name to fall back to the backend-level credentialSecret above. |
| backends[0].tenants[0].groups | list | `["platform-eng"]` | JWT groups authorized to select this tenant |
| backends[0].tenants[0].headers | object | `{"X-MCP-Toolsets":"repos,issues,pull_requests"}` | Optional per-tenant headers (merge over backend headers) |
| backends[0].tenants[0].id | string | `"team-platform"` | Globally unique tenant id (routing key) across ALL backends |
| fullnameOverride | string | `""` | Override the fully qualified name of the chart |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"ghcr.io/loafoe/mt-mcp-proxy"` | Registry repository for the mt-mcp-proxy image |
| image.tag | string | `"v0.3.0"` | Image tag (the release workflow publishes ghcr.io/loafoe/mt-mcp-proxy:<git-tag>) |
| metrics | object | `{"enabled":true,"path":"/metrics","port":9090}` | Prometheus metrics on a SEPARATE listener (isolated from the /mcp data plane). |
| metrics.enabled | bool | `true` | Enable the metrics listener (adds container/service port + config block) |
| metrics.path | string | `"/metrics"` | Path the metrics endpoint is served on |
| metrics.port | int | `9090` | Port the proxy serves Prometheus metrics on |
| nameOverride | string | `""` | Override the name of the chart |
| nodeSelector | object | `{}` | Node selectors |
| replicaCount | int | `1` | Number of proxy replicas (sessions are in-memory; use sticky routing with >1) |
| resources | object | `{}` | Proxy pod resources |
| server.path | string | `"/mcp"` | Exposed MCP endpoint path |
| server.port | int | `8080` | Port the proxy listens on inside the container |
| service.port | int | `8080` | Service port |
| service.type | string | `"ClusterIP"` | Kubernetes Service type for exposing the proxy |
| serviceMonitor | object | `{"enabled":false,"interval":"30s","labels":{},"namespace":"","scrapeTimeout":"10s"}` | ServiceMonitor for Prometheus Operator scraping of the proxy metrics port |
| serviceMonitor.enabled | bool | `false` | Enable ServiceMonitor creation (requires the Prometheus Operator CRDs) |
| serviceMonitor.interval | string | `"30s"` | Scrape interval |
| serviceMonitor.labels | object | `{}` | Additional labels for ServiceMonitor discovery (e.g. release: kube-prometheus-stack) |
| serviceMonitor.namespace | string | `""` | Namespace for the ServiceMonitor (defaults to release namespace) |
| serviceMonitor.scrapeTimeout | string | `"10s"` | Scrape timeout |
| tolerations | list | `[]` | Tolerations |
| tracing | object | `{"enableOnBackends":false,"enabled":false,"endpoint":"http://otel-collector:4317","extraEnv":{},"serviceName":"mt-mcp-proxy"}` | OpenTelemetry tracing. Enabled inside the proxy only when OTEL_EXPORTER_OTLP_ENDPOINT is set. The proxy always injects W3C traceparent on backend calls, so setting OTEL_* on the backend correlates traces. |
| tracing.enableOnBackends | bool | `false` | Also set OTEL_* env on managed backend pods so they join the proxy's trace. OTEL_SERVICE_NAME is derived per backend (<backend-name>-backend). |
| tracing.enabled | bool | `false` | Enable tracing by setting OTEL_* env on the proxy |
| tracing.endpoint | string | `"http://otel-collector:4317"` | OTLP gRPC collector endpoint (sets OTEL_EXPORTER_OTLP_ENDPOINT) |
| tracing.extraEnv | object | `{}` | Additional raw OTEL_* env vars to set on the proxy container |
| tracing.serviceName | string | `"mt-mcp-proxy"` | Service name reported by the proxy (sets OTEL_SERVICE_NAME) |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
