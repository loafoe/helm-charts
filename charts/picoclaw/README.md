# picoclaw

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.0.19](https://img.shields.io/badge/AppVersion-v0.0.19-informational?style=flat-square)

AI-powered Kubernetes operations assistant with multi-channel support (Telegram, Slack, Teams, Pico)

**Homepage:** <https://github.com/loafoe/picoclaw>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Andy Lo-A-Foe | <andy.lo-a-foe@philips.com> |  |

## Source Code

* <https://github.com/loafoe/picoclaw>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| aws.enabled | bool | `false` |  |
| aws.region | string | `"us-east-1"` |  |
| aws.roleArn | string | `""` |  |
| aws.tokenAudience | string | `"sts.amazonaws.com"` |  |
| aws.tokenExpirationSeconds | int | `86400` |  |
| config.agents.defaults.allow_read_outside_workspace | bool | `false` |  |
| config.agents.defaults.max_parallel_turns | int | `5` |  |
| config.agents.defaults.max_tokens | int | `128000` |  |
| config.agents.defaults.max_tool_iterations | int | `50` |  |
| config.agents.defaults.model_name | string | `"bedrock-claude"` |  |
| config.agents.defaults.restrict_to_workspace | bool | `true` |  |
| config.agents.defaults.steering_mode | string | `"one-at-a-time"` |  |
| config.agents.defaults.summarize_message_threshold | int | `20` |  |
| config.agents.defaults.summarize_token_percent | int | `75` |  |
| config.agents.defaults.tool_feedback.enabled | bool | `true` |  |
| config.agents.defaults.tool_feedback.max_args_length | int | `300` |  |
| config.agents.defaults.workspace | string | `"/workspace"` |  |
| config.channels.pico.allow_from | list | `[]` |  |
| config.channels.pico.enabled | bool | `true` |  |
| config.channels.pico.settings.allow_token_query | bool | `true` |  |
| config.channels.pico.settings.max_connections | int | `100` |  |
| config.channels.pico.settings.streaming.enabled | bool | `true` |  |
| config.channels.slack_webhook.enabled | bool | `false` |  |
| config.channels.slack_webhook.settings.webhooks.default.icon_emoji | string | `":crab:"` |  |
| config.channels.slack_webhook.settings.webhooks.default.username | string | `"ClusterClaw"` |  |
| config.channels.teams_webhook.enabled | bool | `false` |  |
| config.channels.telegram.allow_from | list | `[]` |  |
| config.channels.telegram.enabled | bool | `false` |  |
| config.channels.telegram.placeholder.enabled | bool | `true` |  |
| config.channels.telegram.placeholder.text[0] | string | `"Thinking... 💭"` |  |
| config.channels.telegram.settings.streaming.enabled | bool | `true` |  |
| config.channels.telegram.settings.streaming.min_growth_chars | int | `200` |  |
| config.channels.telegram.settings.streaming.throttle_seconds | int | `3` |  |
| config.channels.telegram.settings.use_markdown_v2 | bool | `true` |  |
| config.channels.telegram.typing.enabled | bool | `true` |  |
| config.gateway.host | string | `"0.0.0.0"` |  |
| config.gateway.log_level | string | `"info"` |  |
| config.gateway.port | int | `1337` |  |
| config.models | list | `[]` |  |
| config.tools.exec.enabled | bool | `true` |  |
| config.tools.mcp.enabled | bool | `true` |  |
| config.tools.mcp.servers | object | `{}` |  |
| config.tools.web.enabled | bool | `true` |  |
| config.version | int | `3` |  |
| fullnameOverride | string | `""` |  |
| httpRoute.enabled | bool | `false` |  |
| httpRoute.gatewayRef.name | string | `""` |  |
| httpRoute.gatewayRef.namespace | string | `""` |  |
| httpRoute.gatewayRef.sectionName | string | `""` |  |
| httpRoute.hostname | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"ghcr.io/loafoe/picoclaw"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"picoclaw.local"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"Prefix"` |  |
| ingress.tls | list | `[]` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| picoToken.existingSecret | string | `""` |  |
| picoToken.secretKey | string | `"PICO_TOKEN"` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podSecurityContext.fsGroup | int | `65532` |  |
| podSecurityContext.runAsGroup | int | `65532` |  |
| podSecurityContext.runAsNonRoot | bool | `true` |  |
| podSecurityContext.runAsUser | int | `65532` |  |
| replicaCount | int | `1` |  |
| resources.limits.memory | string | `"128Mi"` |  |
| resources.requests.cpu | string | `"10m"` |  |
| resources.requests.memory | string | `"32Mi"` |  |
| security.content | string | `""` |  |
| security.existingSecret | string | `""` |  |
| securityContext.allowPrivilegeEscalation | bool | `false` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| securityContext.runAsUser | int | `65532` |  |
| service.port | int | `1337` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| soul.content | string | `"# Soul\n\nYour name is **ClusterClaw**. Always introduce yourself as ClusterClaw.\n\nYou are ClusterClaw, an AI operations assistant deployed on a Kubernetes cluster.\n\n## Core Principles\n\n- You help with cluster operations, monitoring, and troubleshooting.\n- You are honest about what you can and cannot do.\n- You never fabricate data — if a tool returns an error, report it.\n- You protect secrets and credentials — never echo tokens or passwords.\n\n## Boundaries\n\n- Do NOT modify this file (SOUL.md) or any system configuration files.\n- Do NOT delete or overwrite files unless explicitly asked by the user.\n- Do NOT execute destructive commands without confirmation.\n"` |  |
| tolerations | list | `[]` |  |
| vpa.enabled | bool | `false` |  |
| vpa.maxAllowed.cpu | string | `"500m"` |  |
| vpa.maxAllowed.memory | string | `"512Mi"` |  |
| vpa.minAllowed.cpu | string | `"5m"` |  |
| vpa.minAllowed.memory | string | `"16Mi"` |  |
| vpa.updateMode | string | `"Off"` |  |
| workspace.enabled | bool | `true` |  |
| workspace.existingClaim | string | `""` |  |
| workspace.size | string | `"1Gi"` |  |
| workspace.storageClassName | string | `""` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
