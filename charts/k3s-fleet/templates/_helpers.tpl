{{- define "k3s-fleet.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "k3s-fleet.fullname" -}}
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

{{- define "k3s-fleet.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/name: {{ include "k3s-fleet.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* Selector labels for one component: api or worker */}}
{{- define "k3s-fleet.selectorLabels" -}}
app.kubernetes.io/name: {{ include "k3s-fleet.name" .ctx }}
app.kubernetes.io/instance: {{ .ctx.Release.Name }}
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{- define "k3s-fleet.serviceAccountName" -}}
{{- $sa := index .ctx.Values .component "serviceAccount" -}}
{{- if $sa.create }}
{{- default (printf "%s-%s" (include "k3s-fleet.fullname" .ctx) .component) $sa.name }}
{{- else }}
{{- default "default" $sa.name }}
{{- end }}
{{- end }}

{{- define "k3s-fleet.image" -}}
{{- $img := index .ctx.Values.image .component -}}
{{- printf "%s/%s:%s" .ctx.Values.image.registry $img.repository (default .ctx.Chart.AppVersion $img.tag) }}
{{- end }}

{{- define "k3s-fleet.dbCluster" -}}
{{- printf "%s-db" (include "k3s-fleet.fullname" .) }}
{{- end }}

{{/* Secret and key holding the PostgreSQL URL: CNPG's <cluster>-app secret, or an existing one */}}
{{- define "k3s-fleet.dbSecretRef" -}}
{{- if .Values.database.cnpg.enabled -}}
name: {{ include "k3s-fleet.dbCluster" . }}-app
key: uri
{{- else -}}
name: {{ required "database.existingSecret.name is required when database.cnpg.enabled is false" .Values.database.existingSecret.name }}
key: {{ .Values.database.existingSecret.key }}
{{- end }}
{{- end }}

{{/* Environment shared by API and worker */}}
{{- define "k3s-fleet.env" -}}
- name: FLEET_API_DATABASE_URL
  valueFrom:
    secretKeyRef:
      {{- include "k3s-fleet.dbSecretRef" . | nindent 6 }}
- name: FLEET_API_LISTEN
  value: ":8080"
{{- end }}
