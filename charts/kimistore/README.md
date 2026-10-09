# kimistore

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)

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
| image.tag | string | `"1.0.0"` |  |
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

## Before you install

The image is `ghcr.io/kimistore/agent`, built with [ko](https://ko.build) and
signed keyless with cosign. Three tags are published:

| Tag | What it is |
|-----|------------|
| `1.0.0` | The current release. Signed, immutable in practice, and what this chart defaults to. |
| `v1.0.0` | The same image, spelled the way the git tag is. Same digest. |
| `main` | The moving branch tip. Convenient in development, worth little as a provenance claim. |

For a deployment you care about, **pin the digest**:

```bash
helm install kimistore oci://ghcr.io/loafoe/helm-charts/kimistore \
  --set image.tag="sha256:4f9a14bb1015d82420230e2fe8129a13005bc2a9f438ff88abaa9b64fb5df695" \
  --set objectStorage.bucket=kimistore \
  --set objectStorage.region=eu-central-1
```

A tag can be repointed after you install, so pinning one proves nothing about
what you are running. The digest does. And verify it:

```bash
cosign verify ghcr.io/kimistore/agent@sha256:4f9a14bb1015d82420230e2fe8129a13005bc2a9f438ff88abaa9b64fb5df695 \
  --certificate-identity-regexp \
    'https://github.com/kimistore/agent/.github/workflows/images.yml@.*' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com
```

Keyless means no key to distribute: Sigstore issues a short-lived certificate
from the workflow's identity and records it in a public transparency log.
Anyone can verify, and a stolen registry credential cannot mint a certificate
that claims to be this workflow. A release image is bound to `refs/tags/v1.0.0`
rather than to a branch, so the signature says which tag produced it.

The image is multi-platform (`linux/arm64` for the Pi nodes, `linux/amd64` for
x86 peers) and runs as uid 65532 to match this chart's `podSecurityContext`. It
is distroless, so there is no shell in it.

`ghcr.io/kimistore/agent-credential` holds `kimistore-credential`, the SCRAM and
ACL administration tool, published under the same tags. It is a separate image
so that a running broker does not carry a binary that can rewrite its own ACLs.

## Install

```bash
helm install kimistore oci://ghcr.io/loafoe/helm-charts/kimistore \
  --set objectStorage.bucket=kimistore \
  --set objectStorage.region=eu-central-1
```

Credentials come from the AWS SDK credential chain by default, so on EKS with
IRSA there is no Secret to create:

```bash
helm install kimistore ... \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=arn:aws:iam::123:role/kimistore
```

For MinIO or RustFS, point the endpoint at it:

```bash
helm install kimistore ... \
  --set objectStorage.endpoint=http://minio.minio.svc:9000 \
  --set objectStorage.accessKeyId=... \
  --set objectStorage.secretAccessKey=...
```

## Things to know

**This is a StatefulSet, not a Deployment.** The agent's write-ahead log lives on
local disk and is the only copy of a record between "producer was acked" and
"segment uploaded to object storage". A Deployment that recreates a pod with a
fresh `emptyDir` discards it. Setting `persistence.enabled=false` is only
appropriate for a throwaway cluster.

**Scaling the replicas up does not share the work by default.** Partition claims
are a race, and the first agent to start wins every one of them. With
`assignment.enabled=false` a three-replica chart runs three agents with one
doing all the work. Set `assignment.enabled=true` to have partitions assigned by
rendezvous hash instead.

**Enabling assignment on a running cluster is not a no-op.** The incumbent
drains the partitions it no longer wins and hands them over. Expect handovers in
the logs (`Assignment: released ...`) rather than a silent no-op.

**Writes cannot go through a load-balanced address.** Clients bootstrap via the
Service, then connect directly to the per-pod addresses that `Metadata` reports.
Each pod advertises its own IP, so a client redirected to "the leader" reaches
it. A shared ClusterIP would mean every broker entry is the same address, and a
producer would land on an arbitrary pod and be refused with
`NOT_LEADER_OR_FOLLOWER`.

**Reads can go through the Service.** Any agent serves a `Fetch` from object
storage, so the Service is a genuine N-way read redundancy rather than only a
bootstrap address.

**Every agent needs a distinct id.** The chart sets `KIMISTORE_AGENT_ID` from the
pod name, which a StatefulSet keeps stable across restarts. Two agents sharing
an id are refused rather than allowed to fight over a partition.

**`terminationGracePeriodSeconds` must exceed 25 seconds.** That is the agent's
drain budget. Below it, eviction truncates a handover and leaves a partition
with a half-uploaded segment. The default here is 60.

**`assignment` and `replicaCount: 1`.** Assignment needs a live set to hash
over, so with one agent it is a no-op. The notes printed after install say so.

## Multi-AZ

Producers must reach the partition leader, so two replicas in one zone give you
neither the availability nor the cost profile you want. Spread across zones:

```yaml
replicaCount: 3
assignment:
  enabled: true
topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: topology.kubernetes.io/zone
    whenUnsatisfiable: ScheduleAnyway
    labelSelector:
      matchLabels:
        app.kubernetes.io/name: kimistore
        app.kubernetes.io/instance: kimistore
```

For a fully zonal deployment, run one release per zone with its own replica
count. Each zone then scales independently, which is the pattern the diskless
Kafka vendors recommend and the reason is traffic skew: one HPA over three zones
reacts to the aggregate, not to the zone that is actually hot.

## Probes

Two endpoints on the metrics port, and they are deliberately different:

- `/live` -- "should this process be killed". Stays 200 through an ownership
  failure. A broker that lost its claims is still a working reader, and
  restarting it removes that reader while gaining nothing.
- `/ready` -- "should clients be sent here". 503 when claims cannot be renewed
  or the cluster view is stale, with the reason in the body.

```bash
kubectl exec kimistore-0 -- wget -qO- http://127.0.0.1:9091/ready
```

The metrics listener binds all interfaces by default. If you bind it to
loopback the probes stop working, so leave `KIMISTORE_METRICS_ADDR` as the
default.

## Write durability

`acks` is a client choice, and it is the single most important thing to get
right:

| `acks` | Promise | Survives losing the pod |
| --- | --- | --- |
| `0` | none | not acknowledged at all |
| `1` | fsynced to local disk | **no** -- the WAL is gone with the node |
| `all` | in object storage | yes |

Use `acks=all` with idempotent producers. That is the only posture that makes a
node loss a non-event, and it is the only one worth it if the data cannot be
replayed.

## Continuous integration

This chart is linted but **not install-tested** by the repository's CI. The
agent's `/ready` endpoint is deliberately honest: it returns 503 when it cannot
renew partition claims or read a fresh cluster view, and in a CI cluster with no
object store neither ever succeeds. The pods start, serve, and stay unready, so
`ct install` waits out its timeout.

Making the probe optimistic to satisfy CI would defeat the reason it exists, so
`kimistore` is listed in the `NOT_INSTALLABLE` set in
`.github/workflows/lint-test.yml` alongside `centcom`. To install-test it against
a real cluster, dispatch that workflow with `chart: kimistore`.

## Metrics worth alerting on

| Metric | Meaning |
|--------|---------|
| `kimistore_build_info` | Version, commit and build date of the running agent |
| `kimistore_partitions_owned` | Partitions this agent holds. Differs per pod by design. |
| `kimistore_manifest_writes_rejected_total` | Non-zero means two agents believed they owned one partition |
| `kimistore_assignment_released_total` | Partitions given up because the assignment moved them |
| `kimistore_assignment_acquired_total` | Partitions taken because the assignment gave them here |
| `kimistore_durable_timeouts_total` | `acks=all` writes that gave up waiting for object storage |
| `kimistore_handover_kept_total` | Handovers that kept their claim because the tail was not durable |

A non-zero `manifest_writes_rejected_total` is the signal that the split-brain
window is being hit. A `released_total` that stays at zero on a multi-replica
release usually means `assignment.enabled` is off.

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)