{{- define "fleetcom.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "fleetcom.fullname" -}}
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

{{- define "fleetcom.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{ include "fleetcom.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "fleetcom.selectorLabels" -}}
app.kubernetes.io/name: {{ include "fleetcom.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "fleetcom.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "fleetcom.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "fleetcom.image" -}}
{{- printf "%s:%s" .Values.image.repository (default .Chart.AppVersion .Values.image.tag) }}
{{- end }}

{{/* The Secret and key holding the session key, as "name/key"; empty when none is configured */}}
{{- define "fleetcom.sessionKeyRef" -}}
{{- $k := .Values.session.key -}}
{{- if $k.existingSecret -}}
{{ $k.existingSecret }}/{{ $k.existingSecretKey }}
{{- else if $k.value -}}
{{ include "fleetcom.fullname" . }}-session/session-key
{{- else if $k.generate -}}
{{ include "fleetcom.fullname" . }}-session/password
{{- end -}}
{{- end }}
