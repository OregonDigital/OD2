{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "oregon.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "oregon.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "oregon.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Shorthand for component names
*/}}
{{- define "oregon.postgres.name" -}}
{{- .Release.Name -}}-postgresql
{{- end -}}
{{- define "oregon.redis.name" -}}
{{- .Release.Name -}}-redis-master
{{- end -}}
{{- define "oregon.web.name" -}}
{{- include "oregon.fullname" . -}}-web
{{- end -}}
{{- define "oregon.sidekiq.name" -}}
{{- include "oregon.fullname" . -}}-sidekiq
{{- end -}}
{{- define "oregon.rails-env.name" -}}
{{- include "oregon.fullname" . -}}-rails-env
{{- end -}}
{{- define "oregon.postgres-env.name" -}}
{{- include "oregon.fullname" . -}}-postgres-env
{{- end -}}
{{- define "oregon.setup.name" -}}
{{- include "oregon.fullname" . -}}-setup
{{- end -}}
{{- define "oregon.zookeeper.name" -}}
{{- include "solr.zookeeper-service-name" . -}}
{{- end -}}
{{- define "oregon.zookeeper-env.name" -}}
{{- include "oregon.fullname" . -}}-zookeeper-env
{{- end -}}
{{- define "oregon.solr.name" -}}
{{- .Release.Name -}}-solr-svc
{{- end -}}
{{- define "oregon.fcrepo.name" -}}
{{- include "oregon.fullname" . -}}-fcrepo
{{- end -}}
{{- define "oregon.fcrepo-env.name" -}}
{{- include "oregon.fullname" . -}}-fcrepo-env
{{- end -}}
{{- define "oregon.rais.name" -}}
{{- include "oregon.fullname" . -}}-rais
{{- end -}}
{{- define "oregon.rais-env.name" -}}
{{- include "oregon.fullname" . -}}-rais-env
{{- end -}}
{{- define "oregon.blazegraph.name" -}}
{{- include "oregon.fullname" . -}}-blazegraph
{{- end -}}
{{- define "oregon.blazegraph-env.name" -}}
{{- include "oregon.fullname" . -}}-blazegraph-env
{{- end -}}
