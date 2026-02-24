# helm-charts

A collection of Helm charts for Kubernetes deployments.

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/loafoe)](https://artifacthub.io/packages/search?repo=loafoe)
[![Release Charts](https://github.com/loafoe/helm-charts/actions/workflows/release.yml/badge.svg)](https://github.com/loafoe/helm-charts/actions/workflows/release.yml)
[![Helm Publish (OCI)](https://github.com/loafoe/helm-charts/actions/workflows/helm.yaml/badge.svg)](https://github.com/loafoe/helm-charts/actions/workflows/helm.yaml)

## Installation

### OCI Registry (recommended)

Charts are published to GitHub Container Registry as OCI artifacts:

```bash
# Pull a chart
helm pull oci://ghcr.io/loafoe/helm-charts/go-hello-world --version 0.15.0

# Install directly
helm install my-release oci://ghcr.io/loafoe/helm-charts/go-hello-world --version 0.15.0
```

### Helm Repository (GitHub Pages)

```bash
# Add the repository
helm repo add loafoe https://loafoe.github.io/helm-charts
helm repo update

# Install a chart
helm install my-release loafoe/go-hello-world
```

## Available Charts

| Chart | Description |
|-------|-------------|
| [go-hello-world](./charts/go-hello-world) | Simple example application |
| [lessor](./charts/lessor) | Caddy plugin for Loki multi-tenant setups |
| [otlp-gateway](./charts/otlp-gateway) | OpenTelemetry gateway deployment |
| [patch-operator](./charts/patch-operator) | Volume/storage CSI expansion operator |
| [solgate](./charts/solgate) | Caddy plugin for path-based service access |

## Contributing

1. Fork this repository
2. Make your changes in a feature branch
3. Submit a pull request

Charts are automatically linted and tested on pull requests.
