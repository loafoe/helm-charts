{{/*
Expand the name of the chart.
*/}}
{{- define "mcp-notifier.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mcp-notifier.fullname" -}}
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
{{- define "mcp-notifier.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mcp-notifier.labels" -}}
helm.sh/chart: {{ include "mcp-notifier.chart" . }}
{{ include "mcp-notifier.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "mcp-notifier.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mcp-notifier.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "mcp-notifier.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "mcp-notifier.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Deterministic env var name for a webhook target's URL, e.g.
(mcp-notifier.webhookEnvVar "SLACK" "default") -> "SLACK_WEBHOOK_DEFAULT_URL"
*/}}
{{- define "mcp-notifier.webhookEnvVar" -}}
{{- $provider := index . 0 -}}
{{- $name := index . 1 -}}
{{- printf "%s_WEBHOOK_%s_URL" ($provider | upper) (regexReplaceAll "[^A-Za-z0-9]" $name "_" | upper) -}}
{{- end }}

{{/*
Deterministic Secret name the chart creates for an inline webhookUrl value,
e.g. (mcp-notifier.inlineSecretName $ "slack" "default") -> "<release>-mcp-notifier-slack-default-webhook"
*/}}
{{- define "mcp-notifier.inlineSecretName" -}}
{{- $root := index . 0 -}}
{{- $provider := index . 1 -}}
{{- $name := index . 2 -}}
{{- printf "%s-%s-%s-webhook" (include "mcp-notifier.fullname" $root) $provider $name | trunc 63 | trimSuffix "-" -}}
{{- end }}
