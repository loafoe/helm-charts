{{/*
Expand the name of the chart.
*/}}
{{- define "otlp-gateway.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "otlp-gateway.fullname" -}}
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
{{- define "otlp-gateway.chart" -}}
{{- if index .Values "$chart_tests" }}
{{- printf "%s" .Chart.Name | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts
*/}}
{{- define "otlp-gateway.namespace" -}}
{{- if .Values.namespaceOverride }}
{{- .Values.namespaceOverride }}
{{- else }}
{{- .Release.Namespace }}
{{- end }}
{{- end }}


{{/*
Calculate name of image ID to use for "alloy.
*/}}
{{- define "otlp-gateway.imageId" -}}
{{- if .Values.image.digest }}
{{- $digest := .Values.image.digest }}
{{- if not (hasPrefix "sha256:" $digest) }}
{{- $digest = printf "sha256:%s" $digest }}
{{- end }}
{{- printf "@%s" $digest }}
{{- else if .Values.image.tag }}
{{- printf ":%s" .Values.image.tag }}
{{- else }}
{{- printf ":%s" .Chart.AppVersion }}
{{- end }}
{{- end }}

{{/*
Calculate name of image ID to use for "config-reloader".
*/}}
{{- define "config-reloader.imageId" -}}
{{- if .Values.configReloader.image.digest }}
{{- $digest := .Values.configReloader.image.digest }}
{{- if not (hasPrefix "sha256:" $digest) }}
{{- $digest = printf "sha256:%s" $digest }}
{{- end }}
{{- printf "@%s" $digest }}
{{- else if .Values.configReloader.image.tag }}
{{- printf ":%s" .Values.configReloader.image.tag }}
{{- else }}
{{- printf ":%s" "v0.8.0" }}
{{- end }}
{{- end }}
