{{/*
Expand the name of the chart.
*/}}
{{- define "go-hello-world.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "go-hello-world.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "go-hello-world.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "go-hello-world.labels" -}}
helm.sh/chart: {{ include "go-hello-world.chart" . }}
{{ include "go-hello-world.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "go-hello-world.selectorLabels" -}}
app.kubernetes.io/name: {{ include "go-hello-world.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "go-hello-world.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "go-hello-world.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate the full HTTPS URL for the app
Uses the first hostname from httpRoute.hostnames or ingress.hosts, or falls back to fullname.clusterFqdn
*/}}
{{- define "go-hello-world.url" -}}
{{- if .Values.httpRoute.enabled -}}
{{- if .Values.httpRoute.hostnames -}}
{{- $hostname := first .Values.httpRoute.hostnames -}}
{{- printf "https://%s" (tpl $hostname .) -}}
{{- else -}}
{{- printf "https://%s.%s" (include "go-hello-world.fullname" .) .Values.environmentConfig.clusterFqdn -}}
{{- end -}}
{{- else if .Values.ingress.enabled -}}
{{- if .Values.ingress.hosts -}}
{{- $host := first .Values.ingress.hosts -}}
{{- printf "https://%s" $host.host -}}
{{- else -}}
{{- printf "https://%s.%s" (include "go-hello-world.fullname" .) .Values.environmentConfig.clusterFqdn -}}
{{- end -}}
{{- else -}}
{{- printf "https://%s.%s" (include "go-hello-world.fullname" .) .Values.environmentConfig.clusterFqdn -}}
{{- end -}}
{{- end }}
