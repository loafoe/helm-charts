# pico-agent Helm Chart

A Helm chart for deploying [pico-agent](https://github.com/loafoe/pico-agent) - a lightweight Kubernetes helper service for webhook-triggered cluster operations.

## Features

- Automatic webhook secret generation (or use existing secret)
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
cosign verify ghcr.io/loafoe/pico-agent:v0.2.0 \
  --certificate-identity-regexp="https://github.com/loafoe/pico-agent/*" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com"
```

## License

MIT License - Copyright (c) 2026 Andy Lo-A-Foe
