# otlp-gateway

![Version: v0.0.1](https://img.shields.io/badge/Version-v0.0.1-informational?style=flat-square) ![AppVersion: v0.3.0](https://img.shields.io/badge/AppVersion-v0.3.0-informational?style=flat-square)

OTLP gateway is a reference implementation which creates a single otlphttp endpoint that proxies Loki, Tempo and Mimir OTLP endpoints
It supports authentication and authorization using both static and JWT tokens and tokens through the [caddy-token](https://github.com/loafoe/caddy-token) plugin.

## Usage

Create the values following the documentation in the next section.
Deploy the Helm chart as an Argo CD application in the cluster. Example command using ArgoCD CLI below

```
argocd app create otlp-gateway-main \
    --repo https://github.com/philips-internal/ien-argocd-apps \
    --path observability/otlp-gateway \
    --revision feature/otlp-proxy \
    --dest-namespace starlift-observability \
    --dest-server https://kubernetes.default.svc \
    --values-literal-file values.yaml \
    --sync-policy auto \
     -N starlift-observability

```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| argoProject | string | `"starlift-observability"` |  |
| authn.oidc.enabled | bool | `true` |  |
| authn.oidc.issuer | string | `"https://dex.us-east-1-foundation-next.bf38001f5e8aa1eb.hsp.philips.com"` |  |
| authn.static_tokens.enabled | bool | `false` |  |
| authn.static_tokens.secret | string | `"otlp-gateway-static-tokens"` |  |
| configReloader.customArgs | list | `[]` | Override the args passed to the container. |
| configReloader.enabled | bool | `true` | Enables automatically reloading when the Alloy config changes. |
| configReloader.image.digest | string | `""` | SHA256 digest of image to use for config reloading (either in format "sha256:XYZ" or "XYZ"). When set, will override `configReloader.image.tag` |
| configReloader.image.registry | string | `"ghcr.io"` | Config reloader image registry (defaults to docker.io) |
| configReloader.image.repository | string | `"jimmidyson/configmap-reload"` | Repository to get config reloader image from. |
| configReloader.image.tag | string | `"v0.12.0"` | Tag of image to use for config reloading. |
| configReloader.resources | object | `{"requests":{"cpu":"1m","memory":"5Mi"}}` | Resource requests and limits to apply to the config reloader container. |
| configReloader.securityContext | object | `{}` | Security context to apply to the Grafana configReloader container. |
| ingress.enabled | bool | `true` |  |
| ingress.host | string | `"otlp-gateway"` |  |
| log.level | string | `"error"` |  |
| replicas | int | `3` |  |
| targetRevision | string | `"main"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.13.1](https://github.com/norwoodj/helm-docs/releases/v1.13.1)