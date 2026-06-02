# Helm Chart: mt-mcp-grafana

A production-grade, multi-tenant Model Context Protocol (MCP) gateway that aggregates and secures multiple `mcp-grafana` server instances speaking the modern **streamable-HTTP** transport.

This Helm chart deploys the `mt-mcp-grafana` proxy gateway along with multiple individual community-supported `mcp-grafana` instances inside the same cluster. It securely wires the entire architecture—routing, configuration, secrets, and in-cluster DNS—automatically.

---

## 1. Architecture Overview

```
              client --(HTTPS, JWT)--> [ mt-mcp-grafana Proxy ]
                                               |
                                     (JWT Signature Verify)
                                     (Group Routing Lookup)
                                               |
                 +-----------------------------+-----------------------------+
                 | (Group: team-a/b)                                         | (Group: team-c)
                 v                                                           v
   [ my-release-team-ab-mcp Service ]                         [ my-release-team-c-mcp Service ]
                 |                                                           |
                 v                                                           v
   [ my-release-team-ab-mcp Pod ]                             [ my-release-team-c-mcp Pod ]
                 | (Secret Ref: Token AB)                                    | (Secret Ref: Token C)
                 v                                                           v
      [ Grafana Instance AB ]                                     [ Grafana Instance C ]
```

1. **Authentication Boundary**: The proxy authenticates incoming LLM/client requests using the configured JWT verification method (`jwks`, `static`, or `insecure`).
2. **Dynamic Routing**: The proxy resolves the backend instance dynamically based on the verified JWT groups, or lets the LLM explicitly select a backend using the `tenant` tool parameter.
3. **Secret Isolation**: Each `mcp-grafana` instance is deployed as an isolated Pod inside the same namespace and references its own Kubernetes Secret containing the Grafana Service Account Token.
4. **Auto-Wiring DNS**: The proxy's `config.yaml` is dynamically generated at release time, linking the proxy to each backend's in-cluster DNS service (`http://<release>-<name>-mcp:8000/mcp`) automatically.

---

## 2. Prerequisites

* Kubernetes 1.20+
* Helm 3.0+
* A running OIDC Issuer (like Keycloak, Auth0, Okta, or Grafana Cloud OIDC) to sign client JWTs.

---

## 3. Installation

Add the local or community repositories and run:

```bash
cd /Users/andy/DEV/Personal/helm-charts
helm install mt-mcp-grafana ./mt-mcp-grafana -f values.yaml
```

---

## 4. Key Configuration Options

### A. JWT Authentication Setup (`values.yaml`)
Configure how the proxy validates client-side JWTs:

```yaml
auth:
  mode: jwks
  groupsClaim: groups
  issuer: "https://auth.company.com/realms/mcp"
  audience: "mcp-grafana"
```

### B. Configuring Managed Backends & Secrets (`values.yaml`)
To deploy multiple isolated backends, list them under `mcpInstances`.

```yaml
mcpInstances:
  - name: team-ab
    groups:
      - team-a
      - team-b
    grafanaUrl: "https://grafana.company.com/team-ab"
    tokenSecret:
      name: team-ab-token-secret
      key: token
      create: true  # Automatically generates the Secret containing the token below
      value: "glsa_my-service-account-token-ab"

  - name: team-c
    groups:
      - team-c
    grafanaUrl: "https://grafana.company.com/team-c"
    tokenSecret:
      name: team-c-token-secret
      key: token
      create: false # Use a pre-existing external Secret (Vault, ExternalSecrets, etc.)
```

---

## 5. Security & Secret Management

For production deployments, storing raw API tokens inside `values.yaml` is highly discouraged. Instead:
1. Set `create: false` for each backend in `values.yaml`.
2. Reference pre-existing Kubernetes Secrets managed by systems like Vault, ExternalSecrets, SealedSecrets, or GitOps pipelines.
3. Ensure the Secret matches the configured `name` and contains the token under the specified `key`.
