# kimistore

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.1.0](https://img.shields.io/badge/AppVersion-v0.1.0-informational?style=flat-square)

Kafka-compatible streaming agent that keeps its durable log in object storage

**Homepage:** <https://github.com/kimistore/agent>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Andy Lo-A-Foe | <andy.loafoe@philips.com> |  |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| agent.autoCreatePartitions | int | `4` |  |
| agent.autoCreateTopics | bool | `true` |  |
| agent.env | object | `{}` |  |
| agent.flushIntervalMs | int | `1000` |  |
| agent.s3TimeoutMs | int | `30000` |  |
| args | list | `[]` |  |
| assignment.enabled | bool | `false` |  |
| assignment.mode | string | `"rendezvous"` |  |
| assignment.settleMs | string | `""` |  |
| broker.port | int | `9092` |  |
| command | list | `[]` |  |
| configMap.create | bool | `true` |  |
| extraContainers | list | `[]` |  |
| extraVolumeMounts | list | `[]` |  |
| extraVolumes | list | `[]` |  |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"ghcr.io/kimistore/agent"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| livenessProbe.failureThreshold | int | `5` |  |
| livenessProbe.periodSeconds | int | `10` |  |
| livenessProbe.timeoutSeconds | int | `5` |  |
| metrics.port | int | `9091` |  |
| nameOverride | string | `""` |  |
| networkPolicy.enabled | bool | `false` |  |
| networkPolicy.extraEgress | list | `[]` |  |
| networkPolicy.extraIngress | list | `[]` |  |
| nodeSelector."kubernetes.io/os" | string | `"linux"` |  |
| objectStorage.accessKeyId | string | `""` |  |
| objectStorage.bucket | string | `""` |  |
| objectStorage.endpoint | string | `""` |  |
| objectStorage.existingSecret | string | `""` |  |
| objectStorage.keys.AWS_ACCESS_KEY_ID | string | `"AWS_ACCESS_KEY_ID"` |  |
| objectStorage.keys.AWS_SECRET_ACCESS_KEY | string | `"AWS_SECRET_ACCESS_KEY"` |  |
| objectStorage.keys.AWS_SESSION_TOKEN | string | `"AWS_SESSION_TOKEN"` |  |
| objectStorage.region | string | `""` |  |
| objectStorage.secretAccessKey | string | `""` |  |
| objectStorage.sessionToken | string | `""` |  |
| ownership.ttlMs | int | `60000` |  |
| persistence.accessMode | string | `"ReadWriteOnce"` |  |
| persistence.annotations | object | `{}` |  |
| persistence.enabled | bool | `true` |  |
| persistence.mountPath | string | `"/var/lib/kimistore/wal"` |  |
| persistence.size | string | `"20Gi"` |  |
| persistence.storageClassName | string | `""` |  |
| persistence.volumeMode | string | `""` |  |
| podAnnotations | object | `{}` |  |
| podDisruptionBudget.enabled | bool | `true` |  |
| podDisruptionBudget.maxUnavailable | string | `""` |  |
| podDisruptionBudget.minAvailable | int | `1` |  |
| podManagementPolicy | string | `"Parallel"` |  |
| podSecurityContext.fsGroup | int | `65532` |  |
| podSecurityContext.runAsGroup | int | `65532` |  |
| podSecurityContext.runAsNonRoot | bool | `true` |  |
| podSecurityContext.runAsUser | int | `65532` |  |
| podSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| priorityClassName | string | `""` |  |
| readinessProbe.failureThreshold | int | `3` |  |
| readinessProbe.periodSeconds | int | `5` |  |
| readinessProbe.timeoutSeconds | int | `5` |  |
| replicaCount | int | `1` |  |
| resources.limits.cpu | string | `"2"` |  |
| resources.limits.memory | string | `"4Gi"` |  |
| resources.requests.cpu | string | `"500m"` |  |
| resources.requests.memory | string | `"1Gi"` |  |
| retention.checkIntervalMs | int | `300000` |  |
| retention.retentionBytes | int | `-1` |  |
| retention.retentionMs | int | `-1` |  |
| sasl.enabled | bool | `false` |  |
| sasl.existingSecret | string | `""` |  |
| sasl.password | string | `""` |  |
| sasl.passwordKey | string | `"password"` |  |
| sasl.username | string | `""` |  |
| sasl.usernameKey | string | `"username"` |  |
| securityContext.allowPrivilegeEscalation | bool | `false` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.readOnlyRootFilesystem | bool | `true` |  |
| service.annotations | object | `{}` |  |
| service.externalTrafficPolicy | string | `""` |  |
| service.loadBalancerIP | string | `""` |  |
| service.loadBalancerSourceRanges | list | `[]` |  |
| service.metrics.clusterIP | bool | `false` |  |
| service.metrics.enabled | bool | `true` |  |
| service.metrics.type | string | `"ClusterIP"` |  |
| service.port | int | `9092` |  |
| service.sessionAffinity | string | `""` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| serviceMonitor.enabled | bool | `false` |  |
| serviceMonitor.interval | string | `"30s"` |  |
| serviceMonitor.labels | object | `{}` |  |
| serviceMonitor.metricRelabelings | list | `[]` |  |
| serviceMonitor.relabelings | list | `[]` |  |
| serviceMonitor.scrapeTimeout | string | `"10s"` |  |
| startupProbe.failureThreshold | int | `60` |  |
| startupProbe.periodSeconds | int | `5` |  |
| startupProbe.timeoutSeconds | int | `5` |  |
| terminationGracePeriodSeconds | int | `60` |  |
| tolerations | list | `[]` |  |
| topologySpreadConstraints | list | `[]` |  |
| updateStrategy.rollingUpdate.maxUnavailable | int | `1` |  |
| updateStrategy.type | string | `"RollingUpdate"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
