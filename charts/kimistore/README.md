# kimistore

Kimistore is a single-binary Kafka-compatible streaming agent that keeps its
durable log in object storage. This chart runs it as a StatefulSet.

> **New here?** Kimistore is pre-1.0. Read the project's
> [README](https://github.com/kimistore/agent) and
> [COMPATIBILITY.md](https://github.com/kimistore/agent/blob/main/COMPATIBILITY.md)
> first. The important constraints for a deployment are the ownership model and
> the write-durability posture, both summarised under "Things to know" below.

## Before you install

**No container image is published yet.** The agent repository has no container
build, so `image.repository` is a placeholder and the pods stay in
`ImagePullBackOff` until you point it at an image you built:

```bash
docker buildx build --platform linux/arm64,linux/amd64 \
  -t ghcr.io/<you>/kimistore:v0.1.0 --push .
```

A placeholder that looks real is worse than one that fails loudly on first
install, so this is stated here rather than hidden in a default.

## Install

```bash
helm install kimistore oci://ghcr.io/loafoe/helm-charts/kimistore \
  --set image.repository=ghcr.io/<you>/kimistore \
  --set objectStorage.bucket=kimistore \
  --set objectStorage.region=eu-central-1
```

Credentials come from the AWS SDK credential chain by default, so on EKS with
IRSA there is no Secret to create:

```bash
# serviceAccount annotated for IRSA
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

- `/live` — "should this process be killed". Stays 200 through an ownership
  failure. A broker that lost its claims is still a working reader, and
  restarting it removes that reader while gaining nothing.
- `/ready` — "should clients be sent here". 503 when claims cannot be renewed or
  the cluster view is stale, with the reason in the body.

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
| `1` | fsynced to local disk | **no** — the WAL is gone with the node |
| `all` | in object storage | yes |

Use `acks=all` with idempotent producers. That is the only posture that makes a
node loss a non-event, and it is the only one worth it if the data cannot be
replayed.

## Values

### Workload

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of broker pods |
| image.repository | string | `"ghcr.io/kimistore/agent"` | Agent image |
| image.tag | string | `""` | Defaults to the chart appVersion |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| imagePullSecrets | list | `[]` | Image pull secrets |
| podManagementPolicy | string | `"Parallel"` | StatefulSet pod management policy |
| terminationGracePeriodSeconds | int | `60` | Must exceed the agent's 25s drain budget |
| updateStrategy.type | string | `"RollingUpdate"` | StatefulSet update strategy |
| updateStrategy.rollingUpdate.maxUnavailable | int | `1` | Max unavailable during rollout |
| updateStrategy.rollingUpdate.partition | int | `nil` | Partition for canary rollouts |
| command | list | `[]` | Override the container command |
| args | list | `[]` | Extra container args |
| priorityClassName | string | `""` | Priority class for the pods |

### Networking

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| broker.port | int | `9092` | Port clients connect to for produce and fetch |
| metrics.port | int | `9091` | Serves `/metrics`, `/ready` and `/live` |
| service.type | string | `"ClusterIP"` | Bootstrap and read Service type |
| service.port | int | `9092` | Bootstrap Service port |
| service.annotations | object | `{}` | Annotations on the broker Service |
| service.loadBalancerIP | string | `""` | Static load balancer IP |
| service.externalTrafficPolicy | string | `""` | For LoadBalancer services |
| service.loadBalancerSourceRanges | list | `[]` | Restrict load balancer sources |
| service.sessionAffinity | string | `""` | Session affinity for the Service |
| service.metrics.enabled | bool | `true` | Create a separate metrics Service |
| service.metrics.type | string | `"ClusterIP"` | Metrics Service type |
| service.metrics.clusterIP | bool | `false` | Annotate for pod-level scraping instead |

### Object storage

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| objectStorage.bucket | string | `""` | Bucket holding the log. Required. |
| objectStorage.region | string | `""` | Bucket region |
| objectStorage.endpoint | string | `""` | For MinIO, RustFS, or other S3-compatible stores |
| objectStorage.accessKeyId | string | `""` | Falls back to this if the credential chain yields nothing |
| objectStorage.secretAccessKey | string | `""` | Falls back to this if the credential chain yields nothing |
| objectStorage.sessionToken | string | `""` | Optional session token |
| objectStorage.existingSecret | string | `""` | Use an existing Secret instead of creating one |
| objectStorage.keys | object | see values | Maps Secret keys to environment variable names |

### Ownership and assignment

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ownership.ttlMs | int | `60000` | Claim lifetime, and therefore the crash failover window |
| assignment.enabled | bool | `false` | Share partitions by rendezvous hash |
| assignment.mode | string | `"rendezvous"` | The only scheme |
| assignment.settleMs | string | `""` | Live-set settle window. Empty uses the agent default. |

### Agent behaviour

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| agent.flushIntervalMs | int | `1000` | Segment seal and upload interval |
| agent.s3TimeoutMs | int | `30000` | Deadline for one object-store request |
| agent.autoCreateTopics | bool | `true` | Create topics on first produce |
| agent.autoCreatePartitions | int | `4` | Partitions for auto-created topics |
| agent.env | object | `{}` | Extra `KIMISTORE_*` variables |
| retention.retentionMs | int | `-1` | Age-based retention. `-1` disables. |
| retention.retentionBytes | int | `-1` | Size-based retention. `-1` disables. |
| retention.checkIntervalMs | int | `300000` | Retention sweep interval |

### Persistence

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| persistence.enabled | bool | `true` | Keep the WAL on a PVC. Disabling loses un-uploaded records. |
| persistence.size | string | `"20Gi"` | PVC size |
| persistence.storageClassName | string | `""` | StorageClass for the WAL volume |
| persistence.accessMode | string | `"ReadWriteOnce"` | PVC access mode |
| persistence.volumeMode | string | `""` | PVC volume mode |
| persistence.mountPath | string | `"/var/lib/kimistore/wal"` | WAL mount path |
| persistence.annotations | object | `{}` | Annotations on the volume claim template |

### Probes

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| livenessProbe.periodSeconds | int | `10` | Liveness period |
| livenessProbe.timeoutSeconds | int | `5` | Liveness timeout |
| livenessProbe.failureThreshold | int | `5` | Liveness failure threshold |
| readinessProbe.periodSeconds | int | `5` | Readiness period |
| readinessProbe.timeoutSeconds | int | `5` | Readiness timeout |
| readinessProbe.failureThreshold | int | `3` | Readiness failure threshold |
| startupProbe.periodSeconds | int | `5` | Startup period |
| startupProbe.timeoutSeconds | int | `5` | Startup timeout |
| startupProbe.failureThreshold | int | `60` | Startup gives 5 minutes for recovery |

### Scheduling

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| nodeSelector | object | `kubernetes.io/os: linux` | Node selector |
| tolerations | list | `[]` | Tolerations |
| affinity | object | `{}` | Affinity rules |
| topologySpreadConstraints | list | `[]` | Spread across nodes and zones |
| podDisruptionBudget.enabled | bool | `true` | Render a PDB. Skipped at one replica. |
| podDisruptionBudget.minAvailable | int | `1` | Minimum available during voluntary disruption |
| podDisruptionBudget.maxUnavailable | string | `""` | Alternative to minAvailable |
| priorityClassName | string | `""` | Priority class |

### Security

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| serviceAccount.create | bool | `true` | Create a ServiceAccount |
| serviceAccount.annotations | object | `{}` | Annotations, e.g. for IRSA |
| serviceAccount.name | string | `""` | Use an existing ServiceAccount |
| podSecurityContext | object | non-root 65532 | Pod-level security context |
| securityContext | object | no privilege escalation | Container security context |
| sasl.enabled | bool | `false` | Enable SASL/PLAIN with one shared credential |
| sasl.existingSecret | string | `""` | Use an existing Secret for the credential |
| sasl.username | string | `""` | Inline username, if not using a Secret |
| sasl.password | string | `""` | Inline password, if not using a Secret |
| sasl.usernameKey | string | `"username"` | Key holding the username |
| sasl.passwordKey | string | `"password"` | Key holding the password |

SCRAM credentials are not configured here. They are created in the bucket with
the `kimistore-credential` tool and discovered by the agent at startup.

### Observability

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| networkPolicy.enabled | bool | `false` | Create a CiliumNetworkPolicy |
| networkPolicy.extraIngress | list | `[]` | Extra ingress rules |
| networkPolicy.extraEgress | list | `[]` | Extra egress rules |
| serviceMonitor.enabled | bool | `false` | Create a Prometheus Operator ServiceMonitor |
| serviceMonitor.interval | string | `"30s"` | Scrape interval |
| serviceMonitor.scrapeTimeout | string | `"10s"` | Scrape timeout |
| serviceMonitor.labels | object | `{}` | Extra labels |
| serviceMonitor.relabelings | list | `[]` | Target relabelings |
| serviceMonitor.metricRelabelings | list | `[]` | Metric relabelings |

### Extras

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| configMap.create | bool | `true` | Render a ConfigMap describing the configuration |
| podAnnotations | object | `{}` | Extra pod annotations |
| extraVolumes | list | `[]` | Extra pod volumes |
| extraVolumeMounts | list | `[]` | Extra volume mounts |
| extraContainers | list | `[]` | Extra sidecar containers |
| nameOverride | string | `""` | Override the chart name |
| fullnameOverride | string | `""` | Override the full name |

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