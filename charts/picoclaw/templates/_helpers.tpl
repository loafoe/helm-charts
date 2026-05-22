{{/*
Expand the name of the chart.
*/}}
{{- define "picoclaw.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "picoclaw.fullname" -}}
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
{{- define "picoclaw.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "picoclaw.labels" -}}
helm.sh/chart: {{ include "picoclaw.chart" . }}
{{ include "picoclaw.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "picoclaw.selectorLabels" -}}
app.kubernetes.io/name: {{ include "picoclaw.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "picoclaw.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "picoclaw.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Security secret name
*/}}
{{- define "picoclaw.securitySecretName" -}}
{{- if .Values.security.existingSecret }}
{{- .Values.security.existingSecret }}
{{- else }}
{{- include "picoclaw.fullname" . }}-security
{{- end }}
{{- end }}

{{/*
Pico token secret name
*/}}
{{- define "picoclaw.picoTokenSecretName" -}}
{{- if .Values.picoToken.existingSecret }}
{{- .Values.picoToken.existingSecret }}
{{- else }}
{{- include "picoclaw.fullname" . }}-pico-token
{{- end }}
{{- end }}

{{/*
Workspace PVC name
*/}}
{{- define "picoclaw.workspacePvcName" -}}
{{- if .Values.workspace.existingClaim }}
{{- .Values.workspace.existingClaim }}
{{- else }}
{{- include "picoclaw.fullname" . }}-workspace
{{- end }}
{{- end }}

{{/*
Image reference
*/}}
{{- define "picoclaw.image" -}}
{{- $tag := default .Chart.AppVersion .Values.image.tag }}
{{- printf "%s:%s" .Values.image.repository $tag }}
{{- end }}
