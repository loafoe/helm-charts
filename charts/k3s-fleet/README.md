# k3s-fleet

![Version: 0.1.4](https://img.shields.io/badge/Version-0.1.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.46.0](https://img.shields.io/badge/AppVersion-0.46.0-informational?style=flat-square)

Fleet API for k3s-on-ec2 clusters - HTTP API (OIDC) and Pulumi job workers, backed by PostgreSQL (CloudNativePG)

The fleet API from [loafoe/k3s-on-ec2](https://github.com/loafoe/k3s-on-ec2)
(`docs/FLEET_API.md` there): create, update, preview and destroy k3s-on-ec2 clusters and
onboard AWS accounts, as asynchronous jobs over HTTP.

- **api** (`ghcr.io/loafoe/k3s-fleet-api`): OIDC-authenticated HTTP API. Never runs Pulumi,
  needs no AWS access.
- **worker** (`ghcr.io/loafoe/k3s-fleet-worker`): claims jobs from the database and runs them
  with the pulumi CLI and baked-in provider plugins. Needs AWS credentials (IRSA).
- **database**: a CloudNativePG `Cluster`, or an existing PostgreSQL 13+ via
  `database.existingSecret`. Jobs, cluster specs and every stack's Pulumi config live here;
  pods are stateless.

## Prerequisites

- The [CloudNativePG operator](https://cloudnative-pg.io) (unless `database.cnpg.enabled=false`).
- An OIDC issuer for callers (`oidc.issuerUrl`, `oidc.audience`). For `fleetctl`, the CLI
  (k3s-on-ec2 `cmd/fleetctl`), the audience is a public client allowed the device code grant:
  `fleetctl login --server <url>` reads the issuer and client ID from the API's `/auth/config`.
- An IAM role for the workers, bound to `<release>-k3s-fleet-worker` via IRSA
  (`worker.serviceAccount.annotations`), allowed to `sts:AssumeRole` the per-account
  `k3s-fleet-deployer` roles and to use the Pulumi state backend. Set the same role as
  `trustedPrincipal.arn`: it is what the deployer roles trust.

## Example

```yaml
oidc:
  issuerUrl: https://login.example.com
  audience: k3s-fleet-api
  requiredGroups: [k3s-fleet-admins]
pulumi:
  backendUrl: s3://ops-tools-pulumi-state?region=eu-west-2
  secretsProvider: awskms://alias/pulumi-k3s-fleet?region=eu-west-2
aws:
  region: eu-west-2
trustedPrincipal:
  arn: arn:aws:iam::633162132188:role/k3s-fleet-worker
worker:
  serviceAccount:
    annotations:
      eks.amazonaws.com/role-arn: arn:aws:iam::633162132188:role/k3s-fleet-worker
httpRoute:
  enabled: true
  parentRefs: [{name: platform, namespace: kube-system}]
  hostnames: [fleet.dip-ops-tools-k3s-eu.hsp.philips.com]
```

Workers get `worker.terminationGracePeriodSeconds` (31 minutes by default) to finish running
jobs on shutdown: interrupting Pulumi mid-update can leave a stack locked.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| api.affinity | object | `{}` |  |
| api.nodeSelector | object | `{}` |  |
| api.podAnnotations | object | `{}` |  |
| api.podDisruptionBudget.enabled | bool | `true` |  |
| api.podDisruptionBudget.minAvailable | int | `1` |  |
| api.podLabels | object | `{}` |  |
| api.replicas | int | `2` | API replicas |
| api.resources.limits.memory | string | `"256Mi"` |  |
| api.resources.requests.cpu | string | `"50m"` |  |
| api.resources.requests.memory | string | `"64Mi"` |  |
| api.service.port | int | `80` |  |
| api.service.type | string | `"ClusterIP"` |  |
| api.serviceAccount.annotations | object | `{}` |  |
| api.serviceAccount.create | bool | `true` |  |
| api.serviceAccount.name | string | `""` | Defaults to <fullname>-api |
| api.tolerations | list | `[]` |  |
| aws.region | string | `""` | AWS region for the workers' SDK calls |
| database.cnpg.enabled | bool | `true` | Create a CloudNativePG Cluster (the CNPG operator must be installed) |
| database.cnpg.imageCatalogRef | object | `{}` | Use an image catalog instead of imageName, e.g. where a policy enforces one: {apiGroup: postgresql.cnpg.io, kind: ClusterImageCatalog, name: default, major: 18} |
| database.cnpg.imageName | string | `"ghcr.io/cloudnative-pg/postgresql:17"` | PostgreSQL image (13+) |
| database.cnpg.instances | int | `2` |  |
| database.cnpg.resources.limits.memory | string | `"1Gi"` |  |
| database.cnpg.resources.requests.cpu | string | `"100m"` |  |
| database.cnpg.resources.requests.memory | string | `"256Mi"` |  |
| database.cnpg.storage.size | string | `"5Gi"` |  |
| database.cnpg.storage.storageClass | string | `""` | Empty uses the default StorageClass |
| database.existingSecret | object | `{"key":"uri","name":""}` | Use an existing database instead (when cnpg.enabled is false): a Secret holding a PostgreSQL URL |
| fullnameOverride | string | `""` |  |
| httpRoute.annotations | object | `{}` |  |
| httpRoute.enabled | bool | `false` | Expose the API through a Gateway API HTTPRoute |
| httpRoute.hostnames | list | `[]` |  |
| httpRoute.parentRefs | list | `[]` | e.g. [{name: platform, namespace: kube-system}] |
| image.api.repository | string | `"loafoe/k3s-fleet-api"` | API image |
| image.api.tag | string | `""` | Defaults to the chart appVersion |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.registry | string | `"ghcr.io"` | Registry for both images |
| image.worker.repository | string | `"loafoe/k3s-fleet-worker"` | Worker image (pulumi CLI + provider plugins) |
| image.worker.tag | string | `""` | Defaults to the chart appVersion |
| imagePullSecrets | list | `[]` | Image pull secrets (the ghcr.io images are public) |
| nameOverride | string | `""` |  |
| oidc.audience | required | `""` | Expected token audience ("aud"), typically the client ID |
| oidc.groupsClaim | string | `"groups"` | Claim holding the caller's groups |
| oidc.issuerUrl | required | `""` | OIDC issuer URL; discovery runs at API start |
| oidc.requiredGroups | list | `[]` | Callers need one of these groups; empty allows any valid token |
| podSecurityContext.fsGroup | int | `65532` |  |
| podSecurityContext.runAsGroup | int | `65532` |  |
| podSecurityContext.runAsNonRoot | bool | `true` |  |
| podSecurityContext.runAsUser | int | `65532` |  |
| podSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| pulumi.accessTokenSecret.key | string | `"token"` |  |
| pulumi.accessTokenSecret.name | string | `""` | Secret with a Pulumi Cloud access token (only for the Pulumi Cloud backend) |
| pulumi.backendUrl | string | `""` | State backend, e.g. s3://bucket?region=eu-west-2. Empty means Pulumi Cloud (set accessTokenSecret). |
| pulumi.secretsProvider | string | `""` | Secrets provider for new stacks, e.g. awskms://alias/pulumi-fleet?region=eu-west-2 |
| securityContext.allowPrivilegeEscalation | bool | `false` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.readOnlyRootFilesystem | bool | `true` |  |
| trustedPrincipal | object | `{"arn":"","arnPattern":""}` | What the per-account k3s-fleet-deployer roles trust: the workers' own AWS identity (their IRSA role) and/or, as an ARN pattern, admins who also run `make up` (e.g. SSO roles, which IAM Identity Center recreates). Set one or both to allow onboarding. |
| worker.affinity | object | `{}` |  |
| worker.concurrency | int | `2` | Jobs per worker pod (each runs a pulumi CLI plus providers: ~1Gi memory per job) |
| worker.nodeSelector | object | `{}` |  |
| worker.podAnnotations | object | `{}` |  |
| worker.podDisruptionBudget.enabled | bool | `true` |  |
| worker.podDisruptionBudget.maxUnavailable | int | `1` | Drains evict one worker at a time; each gets shutdownGrace to finish its jobs |
| worker.podLabels | object | `{}` |  |
| worker.readyTimeout | string | `"45m"` | How long an up waits for the new master to report ready |
| worker.replicas | int | `1` | Worker replicas; jobs are spread over them through the database |
| worker.resources.limits.memory | string | `"3Gi"` |  |
| worker.resources.requests.cpu | string | `"250m"` |  |
| worker.resources.requests.memory | string | `"1Gi"` |  |
| worker.serviceAccount.annotations | object | `{}` | Put the IRSA role here: eks.amazonaws.com/role-arn: arn:aws:iam::<acct>:role/<role> |
| worker.serviceAccount.create | bool | `true` |  |
| worker.serviceAccount.name | string | `""` | Defaults to <fullname>-worker |
| worker.shutdownGrace | string | `"30m"` | On SIGTERM, how long running jobs may finish before they are interrupted |
| worker.terminationGracePeriodSeconds | int | `1860` | Must exceed shutdownGrace, or Kubernetes kills jobs mid-update (stack stays locked) |
| worker.tmpSizeLimit | string | `"4Gi"` | Scratch space for PULUMI_HOME and job work dirs |
| worker.tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
