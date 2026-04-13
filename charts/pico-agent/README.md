# pico-agent Helm Chart

A Helm chart for deploying [pico-agent](https://github.com/loafoe/pico-agent) - a lightweight Kubernetes helper service for webhook-triggered cluster operations.

## Features

- Automatic webhook secret generation (or use existing secret)
- SPIRE/SPIFFE mTLS authentication with multi-trust-domain federation support
- RBAC configuration for PVC resize operations
- Prometheus ServiceMonitor support
- OpenTelemetry tracing support
- Security-hardened deployment

## Installation

```bash
# Add the helm repository
helm repo add loafoe https://loafoe.github.io/helm-charts
helm repo update

# Install with auto-generated secret
helm install pico-agent loafoe/pico-agent -n pico-agent --create-namespace

# Or install with a specific secret
helm install pico-agent loafoe/pico-agent -n pico-agent --create-namespace \
  --set webhook.secret=your-secure-secret-here
```

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `ghcr.io/loafoe/pico-agent` |
| `image.tag` | Image tag | `""` (uses appVersion) |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `webhook.secret` | Webhook secret (if empty, auto-generated) | `""` |
| `webhook.existingSecret` | Name of existing secret | `""` |
| `serviceAccount.create` | Create service account | `true` |
| `rbac.create` | Create RBAC resources | `true` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `8080` |
| `service.metricsPort` | Metrics port | `9090` |
| `observability.logLevel` | Log level | `info` |
| `observability.logFormat` | Log format (json/text) | `json` |
| `observability.otelEndpoint` | OpenTelemetry endpoint | `""` |
| `serviceMonitor.enabled` | Enable Prometheus ServiceMonitor | `false` |
| `spire.enabled` | Enable SPIRE authentication | `false` |
| `spire.agentSocket` | SPIRE agent socket path | `unix:///run/spire/agent/sockets/spire-agent.sock` |
| `spire.trustDomains` | List of SPIFFE trust domains (supports federation) | `[]` |
| `spire.trustDomain` | Single trust domain (legacy, use trustDomains) | `""` |
| `spire.allowedSPIFFEIDs` | List of allowed SPIFFE IDs | `[]` |
| `spire.jwt.enabled` | Enable JWT-SVID authentication | `false` |
| `spire.jwt.audiences` | Expected JWT audiences | `[]` |
| `resources.limits.cpu` | CPU limit | `100m` |
| `resources.limits.memory` | Memory limit | `128Mi` |
| `resources.requests.cpu` | CPU request | `10m` |
| `resources.requests.memory` | Memory request | `32Mi` |

## Webhook Secret Management

The chart supports three modes for webhook secret management:

### 1. Auto-generated (default)

If neither `webhook.secret` nor `webhook.existingSecret` is provided, the chart creates a Kubernetes Job that generates a random secret.

```bash
helm install pico-agent loafoe/pico-agent -n pico-agent --create-namespace

# Retrieve the generated secret
kubectl get secret pico-agent-webhook -n pico-agent -o jsonpath='{.data.secret}' | base64 -d
```

### 2. Explicit secret

Provide the secret directly in values:

```bash
helm install pico-agent loafoe/pico-agent -n pico-agent --create-namespace \
  --set webhook.secret=my-super-secret-value
```

### 3. Existing secret

Reference a pre-existing Kubernetes secret:

```bash
# Create secret first
kubectl create secret generic my-webhook-secret -n pico-agent --from-literal=secret=my-value

# Install chart
helm install pico-agent loafoe/pico-agent -n pico-agent \
  --set webhook.existingSecret=my-webhook-secret
```

## SPIRE/SPIFFE Authentication

As an alternative to webhook signature verification, pico-agent supports SPIRE authentication with multi-trust-domain federation. Two modes are available:

- **X.509 mTLS**: Client presents X.509 SVID certificate during TLS handshake
- **JWT-SVID**: Client sends JWT token in `Authorization: Bearer <token>` header

### X.509 mTLS (Single Trust Domain)

```bash
helm install pico-agent loafoe/pico-agent -n pico-agent --create-namespace \
  --set spire.enabled=true \
  --set 'spire.trustDomains[0]=example.org' \
  --set 'spire.allowedSPIFFEIDs[0]=spiffe://example.org/ai-agent'
```

### X.509 mTLS (Federated Trust Domains)

For cross-organization SPIFFE federation:

```bash
helm install pico-agent loafoe/pico-agent -n pico-agent --create-namespace \
  --set spire.enabled=true \
  --set 'spire.trustDomains[0]=example.org' \
  --set 'spire.trustDomains[1]=partner.com' \
  --set 'spire.allowedSPIFFEIDs[0]=spiffe://example.org/ai-agent' \
  --set 'spire.allowedSPIFFEIDs[1]=spiffe://partner.com/service'
```

### JWT-SVID Authentication

JWT-SVID is useful when mTLS is not feasible (e.g., through load balancers or API gateways):

```bash
helm install pico-agent loafoe/pico-agent -n pico-agent --create-namespace \
  --set spire.enabled=true \
  --set 'spire.trustDomains[0]=example.org' \
  --set spire.jwt.enabled=true \
  --set 'spire.jwt.audiences[0]=pico-agent' \
  --set 'spire.allowedSPIFFEIDs[0]=spiffe://example.org/ai-agent'
```

Clients authenticate by including the JWT-SVID in requests:

```bash
curl -X POST http://pico-agent:8080/task \
  -H "Authorization: Bearer <jwt-svid-token>" \
  -H "Content-Type: application/json" \
  -d '{"type":"pv_resize","payload":{...}}'
```

### Combined Authentication

You can enable both X.509 mTLS and JWT-SVID. The server accepts either method. When SPIRE is enabled, webhook signature verification remains available as a fallback.

## Usage with Grafana Alertmanager

Configure your Grafana Alertmanager contact point:

1. Get the webhook secret:
   ```bash
   kubectl get secret pico-agent-webhook -n pico-agent -o jsonpath='{.data.secret}' | base64 -d
   ```

2. Create a webhook contact point in Grafana with:
   - **URL**: `http://pico-agent.pico-agent.svc.cluster.local:8080/task`
   - **HTTP Method**: POST
   - **Authorization Header**: Configure HMAC signing with the secret

3. Send a PV resize payload:
   ```json
   {
     "type": "pv_resize",
     "payload": {
       "namespace": "default",
       "pvc_name": "my-pvc",
       "new_size": "20Gi"
     }
   }
   ```

4. Or wait for completion (synchronous):
   ```json
   {
     "type": "pv_resize",
     "payload": {
       "namespace": "default",
       "pvc_name": "my-pvc",
       "new_size": "20Gi",
       "wait": true,
       "timeout": "5m"
     }
   }
   ```

   Response with details:
   ```json
   {
     "success": true,
     "message": "PVC default/my-pvc resized from 10Gi to 20Gi",
     "details": {
       "duration": "45.2s",
       "final_size": "20Gi"
     }
   }
   ```

## Image Verification

The pico-agent images are signed with cosign. Verify before deployment:

```bash
cosign verify ghcr.io/loafoe/pico-agent:v0.4.0 \
  --certificate-identity-regexp="https://github.com/loafoe/pico-agent/*" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com"
```

## License

MIT License - Copyright (c) 2026 Andy Lo-A-Foe
