# fleetcom

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.64.1](https://img.shields.io/badge/AppVersion-0.64.1-informational?style=flat-square)

fleetcom - OIDC-protected web UI over the k3s-on-ec2 fleet API (clusters, accounts, jobs with live logs, workers)

fleetcom from [loafoe/k3s-on-ec2](https://github.com/loafoe/k3s-on-ec2) (`docs/FLEETCOM.md`
there) is the web UI of the fleet API (chart [k3s-fleet](../k3s-fleet)), with Centcom's look:
clusters with their spec, outputs and control plane, accounts, jobs with the log followed live,
workers. Read-only for now.

- **Login**: OIDC authorization code flow with PKCE. By default fleetcom logs in **as the fleet
  API's own client** (issuer and client ID from the API's `/auth/config`), so the ID token carries
  the API's audience, and forwards it to the API: the API's group and connector checks decide
  what each user sees.
- **Stateless**: tokens live in sealed, `HttpOnly` cookies. Replicas only need to share the
  session key.

## Prerequisites

- The fleet API, reachable from fleetcom (`fleetApi.url`, e.g. the k3s-fleet chart's Service).
- The redirect URI `<baseUrl>/callback` registered on the OIDC client fleetcom logs in with. For
  dex and the fleet API's public client:

  ```yaml
  redirectURIs:
    - /device/callback                         # fleetctl
    - https://fleetcom.example.com/callback    # fleetcom
  ```
- A session key shared by the replicas: `session.key.generate` (needs the
  [external-secrets](https://external-secrets.io) operator: a `Password` generator fills the
  Secret once), `session.key.existingSecret`, or `session.key.value`.

## Example

```yaml
fleetApi:
  url: http://k3s-fleet-api.k3s-fleet.svc
baseUrl: https://fleetcom.example.com
session:
  key:
    generate: true
httpRoute:
  enabled: true
  parentRefs: [{name: platform, namespace: kube-system}]
  hostnames: [fleetcom.example.com]
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| baseUrl | required | `""` | fleetcom's public URL, e.g. https://fleetcom.example.com. The OIDC redirect URI is <baseUrl>/callback: register it on the OIDC client. |
| extraEnv | list | `[]` | Extra environment variables for the container |
| fleetApi.url | required | `""` | How fleetcom reaches the fleet API, e.g. the k3s-fleet chart's Service: http://k3s-fleet-api.k3s-fleet.svc |
| fullnameOverride | string | `""` |  |
| httpRoute.annotations | object | `{}` |  |
| httpRoute.enabled | bool | `false` | Expose fleetcom with a Gateway API HTTPRoute |
| httpRoute.hostnames | list | `[]` | Hostnames, e.g. [fleetcom.example.com]; baseUrl must be one of them |
| httpRoute.parentRefs | required when enabled | `[]` | Gateways to attach to, e.g. [{name: platform, namespace: kube-system}] |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"ghcr.io/loafoe/fleetcom"` | Image repository |
| image.tag | string | `""` | Defaults to the chart appVersion |
| imagePullSecrets | list | `[]` | Image pull secrets (the image is public) |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| oidc.clientId | string | `""` | Client ID. Empty: the fleet API's audience, the client fleetctl logs in with. Tokens must carry the API's audience, so keep the default unless the API accepts another client. |
| oidc.clientSecret.existingSecret | string | `""` | Secret with the client secret, for a confidential client. Empty: a public client (PKCE) |
| oidc.clientSecret.key | string | `"client-secret"` | Key in that Secret |
| oidc.groupsClaim | string | `""` | Groups claim shown on the profile and access-denied pages. Empty: the fleet API's |
| oidc.issuer | string | `""` | Issuer URL. Empty: the fleet API's (its /auth/config) |
| oidc.scopes | list | `[]` | Scopes. Empty: openid, email, profile, groups, offline_access plus what /auth/config asks for |
| podAnnotations | object | `{}` |  |
| podDisruptionBudget.enabled | bool | `true` | Keep one replica through voluntary disruptions (only rendered with replicas > 1) |
| podDisruptionBudget.minAvailable | int | `1` |  |
| podLabels | object | `{}` |  |
| podSecurityContext.runAsGroup | int | `65532` |  |
| podSecurityContext.runAsNonRoot | bool | `true` |  |
| podSecurityContext.runAsUser | int | `65532` |  |
| podSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| replicas | int | `2` | Replicas. More than one needs a shared session key (session.key) |
| resources.limits.memory | string | `"128Mi"` |  |
| resources.requests.cpu | string | `"10m"` |  |
| resources.requests.memory | string | `"32Mi"` |  |
| securityContext.allowPrivilegeEscalation | bool | `false` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.readOnlyRootFilesystem | bool | `true` |  |
| service.port | int | `80` | Service port |
| service.type | string | `"ClusterIP"` | Service type |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` | Create a ServiceAccount (fleetcom needs no Kubernetes API access; its token is not mounted) |
| serviceAccount.name | string | `""` | Defaults to the fullname |
| session.key.existingSecret | string | `""` | Existing Secret with the key (at least 32 random characters, e.g. openssl rand -base64 32) |
| session.key.existingSecretKey | string | `"session-key"` | Key in that Secret |
| session.key.generate | bool | `false` | Generate the key once with External Secrets' Password generator into <fullname>-session (the external-secrets operator must be installed). Never rotated by itself: delete the Secret to rotate (everyone logs in again). |
| session.key.value | string | `""` | The key inline; the chart keeps it in a Secret. Prefer generate or existingSecret |
| session.ttl | string | `"12h"` | How long a login lasts, token renewals included |
| tolerations | list | `[]` |  |
| topologySpreadConstraints | list | `[]` | Spread constraints; the selector labels are filled in when labelSelector is omitted |
| version | string | `""` | Shown in the sidebar. Empty: the image tag |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
