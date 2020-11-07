{{- define "mongodb.serviceName" -}}
{{ .Release.Name }}-mongodb-service
{{- end -}}