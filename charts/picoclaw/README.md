# Picoclaw Helm Chart

AI-powered Kubernetes operations assistant with multi-channel support (Telegram, Slack, Teams, Pico WebSocket).

## Overview

Picoclaw (ClusterClaw) is an AI assistant that helps with Kubernetes cluster operations through natural language. It supports multiple communication channels and integrates with MCP (Model Context Protocol) servers for extended functionality.

## Installation

```bash
helm install picoclaw ./charts/picoclaw -n picoclaw --create-namespace -f values.yaml
```

## Architecture

### Configuration Flow

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   ConfigMap     │     │     Secret      │     │   ConfigMap     │
│  (config.json)  │     │ (.security.yml) │     │   (SOUL.md)     │
└────────┬────────┘     └────────┬────────┘     └────────┬────────┘
         │                       │                       │
         │ initContainer         │ initContainer         │ initContainer
         │ (copy-config)         │ (copy-config)         │ (copy-soul)
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                        /config/                                  │
│  config.json + .security.yml (writable emptyDir)                │
└─────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│                     picoclaw container                           │
│  - Reads /config/config.json                                    │
│  - SOUL.md at /workspace/SOUL.md (read-only, owned by root)     │
│  - Workspace at /workspace/ (persistent)                        │
└─────────────────────────────────────────────────────────────────┘
```

### SOUL.md Security

The SOUL.md file defines the AI's personality, rules, and boundaries. It is protected through multiple layers:

1. **ConfigMap Source**: SOUL.md content is stored in a ConfigMap, version-controlled via Helm
2. **Root Ownership**: An init container running as root copies SOUL.md to `/workspace/SOUL.md` and sets ownership to `root:root`
3. **Read-Only Permissions**: File permissions are set to `444` (read-only for all)
4. **Non-Root Runtime**: The main container runs as non-root user (65532), preventing modification

This ensures the AI cannot modify its own rules, even if instructed to do so.

### Workspace Persistence

The `/workspace` directory is backed by a PersistentVolumeClaim for:
- Session data storage
- Skill files
- Memory files
- Temporary artifacts

Each user session stores files in `/workspace/sessions/<session_id>/` for isolation.

## Configuration

### Required Secrets

Before deploying, you need to create secrets for:

#### 1. Security Configuration (`.security.yml`)

Contains Telegram bot tokens, API keys, etc. Create manually:

```bash
kubectl create secret generic picoclaw-security -n picoclaw \
  --from-file=.security.yml=security.yml
```

Example `.security.yml`:
```yaml
telegram:
  bot_token: "your-telegram-bot-token"
```

Then reference it in values:
```yaml
security:
  existingSecret: "picoclaw-security"
```

#### 2. Pico Channel Token

For WebSocket authentication with pico-mcp:

```bash
kubectl create secret generic picoclaw-pico-token -n picoclaw \
  --from-literal=PICO_TOKEN="your-secure-token"
```

Then reference it:
```yaml
picoToken:
  existingSecret: "picoclaw-pico-token"
```

### MCP Server Configuration

Picoclaw integrates with MCP servers for extended capabilities. Example configuration:

```yaml
config:
  tools:
    mcp:
      enabled: true
      servers:
        pico-mcp:
          enabled: true
          type: http
          url: "http://pico-mcp.pico-mcp.svc.cluster.local:8080/mcp"
          dynamic_headers:
            allowed:
              - "X-Grafana-Service-Account-Token"
              - "Authorization"
        grafana-mcp:
          enabled: true
          type: http
          url: "http://grafana-mcp.grafana-mcp.svc.cluster.local:8000/mcp"
```

**MCP Server Types:**
- `http`: HTTP-based MCP server (most common for in-cluster services)
- `sse`: Server-Sent Events transport
- `stdio`: Standard I/O (for local processes)

**Dynamic Headers:** Allow passing authentication headers from the user's session to MCP servers. Useful for per-user authorization.

### Model Configuration

Configure AI model providers:

```yaml
config:
  models:
    - model_name: "bedrock-claude"
      model: "bedrock/us.anthropic.claude-opus-4-6-v1"
      api_base: "us-east-1"
```

For AWS Bedrock, enable AWS IAM:

```yaml
aws:
  enabled: true
  roleArn: "arn:aws:iam::123456789:role/picoclaw-bedrock-access"
  region: "us-east-1"

serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::123456789:role/picoclaw-bedrock-access"
```

### Channel Configuration

#### Telegram

```yaml
config:
  channels:
    telegram:
      enabled: true
      allow_from:
        - "123456789"  # Allowed user IDs
      settings:
        streaming:
          enabled: true
          throttle_seconds: 3
```

#### Pico (WebSocket)

Used by pico-mcp for the ClusterClaw chat interface:

```yaml
config:
  channels:
    pico:
      enabled: true
      settings:
        allow_token_query: true
        streaming: true
        max_connections: 100
```

#### Slack Webhook

```yaml
config:
  channels:
    slack_webhook:
      enabled: true
      settings:
        webhooks:
          default:
            username: "ClusterClaw"
            icon_emoji: ":crab:"
```

### VPA (Vertical Pod Autoscaler)

Enable VPA for resource recommendations:

```yaml
vpa:
  enabled: true
  updateMode: "Off"  # Off = recommendations only, Auto = apply automatically
  minAllowed:
    cpu: 5m
    memory: 16Mi
  maxAllowed:
    cpu: 500m
    memory: 512Mi
```

## Values Reference

| Key | Description | Default |
|-----|-------------|---------|
| `replicaCount` | Number of replicas (use 1 for stateful workspace) | `1` |
| `image.repository` | Container image repository | `ghcr.io/loafoe/picoclaw` |
| `image.tag` | Container image tag | `""` (uses appVersion) |
| `config.agents.defaults.model_name` | Default model name | `"bedrock-claude"` |
| `config.agents.defaults.max_tokens` | Max token context | `128000` |
| `config.gateway.port` | Gateway listen port | `1337` |
| `soul.content` | SOUL.md content (AI rules) | See values.yaml |
| `security.existingSecret` | Existing secret for .security.yml | `""` |
| `picoToken.existingSecret` | Existing secret for Pico token | `""` |
| `aws.enabled` | Enable AWS IAM for Bedrock | `false` |
| `aws.roleArn` | AWS IAM role ARN | `""` |
| `workspace.enabled` | Enable persistent workspace | `true` |
| `workspace.size` | Workspace PVC size | `1Gi` |
| `resources.requests.cpu` | CPU request | `10m` |
| `resources.requests.memory` | Memory request | `32Mi` |
| `resources.limits.memory` | Memory limit | `128Mi` |
| `vpa.enabled` | Enable VPA | `false` |
| `service.port` | Service port | `1337` |

## Example: Full Production Setup

```yaml
# values-production.yaml
image:
  tag: v0.0.19

config:
  agents:
    defaults:
      model_name: "bedrock-claude"
      max_tokens: 128000

  channels:
    telegram:
      enabled: true
      allow_from: ["123456789", "987654321"]
    pico:
      enabled: true

  models:
    - model_name: "bedrock-claude"
      model: "bedrock/us.anthropic.claude-opus-4-6-v1"
      api_base: "us-east-1"

  tools:
    mcp:
      enabled: true
      servers:
        pico-mcp:
          enabled: true
          type: http
          url: "http://pico-mcp.pico-mcp.svc.cluster.local:8080/mcp"
          dynamic_headers:
            allowed: ["Authorization"]

soul:
  content: |
    # Soul
    Your name is **ClusterClaw**.
    # ... customize as needed

security:
  existingSecret: "picoclaw-security"

picoToken:
  existingSecret: "picoclaw-pico-token"

aws:
  enabled: true
  roleArn: "arn:aws:iam::123456789:role/picoclaw-bedrock-access"
  region: "us-east-1"

serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::123456789:role/picoclaw-bedrock-access"

workspace:
  enabled: true
  size: 5Gi
  storageClassName: "gp3-encrypted"

vpa:
  enabled: true
  updateMode: "Off"

resources:
  requests:
    cpu: 10m
    memory: 32Mi
  limits:
    memory: 128Mi
```

## Troubleshooting

### Pod not starting

1. Check secrets exist:
   ```bash
   kubectl get secret -n picoclaw
   ```

2. Check init container logs:
   ```bash
   kubectl logs -n picoclaw deploy/picoclaw -c copy-config
   kubectl logs -n picoclaw deploy/picoclaw -c copy-soul
   ```

### AI not responding

1. Check main container logs:
   ```bash
   kubectl logs -n picoclaw deploy/picoclaw
   ```

2. Verify config is correct:
   ```bash
   kubectl exec -n picoclaw deploy/picoclaw -- cat /config/config.json
   ```

### AWS Bedrock errors

1. Verify IAM token is mounted:
   ```bash
   kubectl exec -n picoclaw deploy/picoclaw -- cat /var/run/secrets/eks.amazonaws.com/serviceaccount/token
   ```

2. Check IAM role trust policy allows the ServiceAccount
