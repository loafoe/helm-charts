# pico-mcp

![Version: 0.42.0](https://img.shields.io/badge/Version-0.42.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.49.1](https://img.shields.io/badge/AppVersion-v0.49.1-informational?style=flat-square)

MCP server for managing multiple pico-agent instances

**Homepage:** <https://github.com/loafoe/pico-mcp>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Andy Lo-A-Foe | <andy.lo-a-foe@philips.com> |  |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| agents[0].id | string | `"cluster-alpha"` |  |
| agents[0].jwt_audience | string | `"pico-agent-alpha"` |  |
| agents[0].url | string | `"http://pico-agent.alpha.svc.cluster.local:8080"` |  |
| agents[1].id | string | `"cluster-beta"` |  |
| agents[1].jwt_audience | string | `"pico-agent-beta"` |  |
| agents[1].url | string | `"http://pico-agent.beta.svc.cluster.local:8080"` |  |
| alerts.pvUsage.autoRemediate | bool | `false` |  |
| alerts.pvUsage.cooldown | string | `"1h"` |  |
| alerts.pvUsage.enabled | bool | `false` |  |
| alerts.pvUsage.interval | string | `"5m"` |  |
| alerts.pvUsage.thresholdPercent | int | `80` |  |
| cron.defaultChannel | string | `"cron:system"` |  |
| cron.enabled | bool | `false` |  |
| database.barmanBackup.bucketName | string | `""` |  |
| database.barmanBackup.bucketPrefix | string | `""` |  |
| database.barmanBackup.compression | string | `"gzip"` |  |
| database.barmanBackup.enabled | bool | `false` |  |
| database.barmanBackup.retentionDays | int | `7` |  |
| database.cnpg | bool | `true` |  |
| database.databaseName | string | `"picomcp"` |  |
| database.enabled | bool | `false` |  |
| database.engineVersion | string | `"18.1"` |  |
| database.identifier | string | `""` |  |
| database.restoreFromBarman.enabled | bool | `false` |  |
| database.restoreFromBarman.targetTime | string | `""` |  |
| database.restoreFromSnapshot | bool | `false` |  |
| database.restoreFromVolumeSnapshot.enabled | bool | `false` |  |
| database.restoreFromVolumeSnapshot.sourceIdentifier | string | `""` |  |
| database.restoreFromVolumeSnapshot.storageClassName | string | `""` |  |
| database.size | string | `"small"` |  |
| database.snapshotId | string | `""` |  |
| database.snapshots.enabled | bool | `false` |  |
| database.snapshots.snapshotClassName | string | `""` |  |
| database.snapshots.storageClassName | string | `""` |  |
| database.username | string | `"picomcp"` |  |
| features.getResource | bool | `false` |  |
| fullnameOverride | string | `""` |  |
| httpRoute.annotations | object | `{}` |  |
| httpRoute.enabled | bool | `false` |  |
| httpRoute.gatewayRef.name | string | `"platform"` |  |
| httpRoute.gatewayRef.namespace | string | `"kube-system"` |  |
| httpRoute.gatewayRef.sectionName | string | `"https"` |  |
| httpRoute.hostname | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"ghcr.io/loafoe/pico-mcp"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| ipAllowlist.cidrs | list | `[]` |  |
| ipAllowlist.enabled | bool | `false` |  |
| leaderElection.enabled | bool | `false` |  |
| nameOverride | string | `""` |  |
| networkPolicy.enabled | bool | `false` |  |
| nodeSelector."kubernetes.io/os" | string | `"linux"` |  |
| otel.captureContent | bool | `false` |  |
| otel.enabled | bool | `false` |  |
| otel.endpoint | string | `""` |  |
| otel.protocol | string | `"grpc"` |  |
| picoclaw.enabled | bool | `false` |  |
| picoclaw.tokenSecret.key | string | `"token"` |  |
| picoclaw.tokenSecret.name | string | `""` |  |
| picoclaw.url | string | `""` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext.fsGroup | int | `65532` |  |
| podSecurityContext.runAsGroup | int | `65532` |  |
| podSecurityContext.runAsNonRoot | bool | `true` |  |
| podSecurityContext.runAsUser | int | `65532` |  |
| podSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| replicaCount | int | `1` |  |
| resources.limits.cpu | string | `"100m"` |  |
| resources.limits.memory | string | `"128Mi"` |  |
| resources.requests.cpu | string | `"10m"` |  |
| resources.requests.memory | string | `"32Mi"` |  |
| securityContext.allowPrivilegeEscalation | bool | `false` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.readOnlyRootFilesystem | bool | `true` |  |
| server.baseURL | string | `""` |  |
| server.port | int | `8080` |  |
| server.transport | string | `"sse"` |  |
| service.port | int | `8080` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| serviceIdentity.audience | string | `""` |  |
| serviceIdentity.enabled | bool | `false` |  |
| serviceIdentity.iamURL | string | `""` |  |
| serviceIdentity.oidcIssuer | string | `""` |  |
| serviceIdentity.privateKeySecret.key | string | `"private-key"` |  |
| serviceIdentity.privateKeySecret.name | string | `""` |  |
| serviceIdentity.serviceId | string | `""` |  |
| serviceMonitor | object | `{"enabled":false,"interval":"30s","labels":{},"metricRelabelings":[],"namespace":"","relabelings":[],"scrapeTimeout":"10s","targetLabels":[]}` | ServiceMonitor for Prometheus Operator scraping |
| serviceMonitor.enabled | bool | `false` | Enable ServiceMonitor creation |
| serviceMonitor.interval | string | `"30s"` | Scrape interval |
| serviceMonitor.labels | object | `{}` | Additional labels for ServiceMonitor discovery |
| serviceMonitor.metricRelabelings | list | `[]` | Metric relabeling rules |
| serviceMonitor.namespace | string | `""` | Namespace for the ServiceMonitor (defaults to release namespace) |
| serviceMonitor.relabelings | list | `[]` | Relabeling rules |
| serviceMonitor.scrapeTimeout | string | `"10s"` | Scrape timeout |
| serviceMonitor.targetLabels | list | `[]` | Target labels to transfer from the Service to scraped metrics |
| spire.agentSocket | string | `"unix:///spiffe-workload-api/spire-agent.sock"` |  |
| spire.csi.enabled | bool | `true` |  |
| spire.enabled | bool | `true` |  |
| spire.hostSocketPath | string | `"/run/spire/agent-sockets"` |  |
| spire.socketMountPath | string | `"/spiffe-workload-api"` |  |
| tolerations | list | `[]` |  |
| ui.logo.enabled | bool | `false` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
