{{- define "mongodb.serviceName" -}}
{{ .Release.Name }}-mongodb
{{- end -}}