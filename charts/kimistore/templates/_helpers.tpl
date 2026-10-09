{{/*
Expand the name of the chart.
*/}}
{{- define "kimistore.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kimistore.fullname" -}}
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
{{- define "kimistore.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kimistore.labels" -}}
helm.sh/chart: {{ include "kimistore.chart" . }}
{{ include "kimistore.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels

The selector must NOT include a pod-ordinal label, so that a rolling update can
replace one pod at a time without the selector changing under it.
*/}}
{{- define "kimistore.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kimistore.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "kimistore.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "kimistore.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Name of the headless service that gives each pod a stable DNS name.

It is deliberately not the main service name, so the client-facing Service can
be changed without the StatefulSet's serviceName moving out from under running
pods.
*/}}
{{- define "kimistore.headlessServiceName" -}}
{{- printf "%s-headless" (include "kimistore.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Name of the PVC template.

A StatefulSet gets one volumeClaimTemplate per volume and names the resulting
claim after the pod, so the template itself needs no name of its own. This
exists only when persistence is disabled, for the emptyDir case.
*/}}
{{- define "kimistore.walVolumeName" -}}
wal
{{- end }}

{{/*
The per-zone cluster identity.

Two releases in the same bucket must not share this, and it must be stable
across upgrades. It is namespaced with the release name rather than being
derived from a single global value so two clusters can share a bucket prefix
without colliding on ownership claims.
*/}}
{{- define "kimistore.namespaceName" -}}
{{- printf "%s-%s" .Release.Namespace (include "kimistore.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}