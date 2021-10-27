{{- /* Create and return AuthConfig Name */}}
{{- define "getAuthConfigName" -}}
  {{- $ext := "no-headerextension" -}}
  {{- if eq true (index . 2) -}}
    {{- $ext = "with-headerextension" -}}
  {{- end -}}
  {{- printf "%s-%s-%s" (index . 0) (index . 1) $ext }}
{{- end -}}
{{- define "getVirtualServiceName" -}}
  {{- printf "%s-%d" (index . 0) (index . 1) }}
{{- end -}}
{{- define "getAppUrl" -}}
  {{- $values := index . 0 -}}
  {{- $ := index . 1 -}}
  {{- printf "https://%s.%s" $values.svc (first $.Values.defaults.domains) }}
{{- end -}} 
{{- define "getSvcDomain" -}}
  {{- $values := index . 0 -}}
  {{- $ := index . 1 -}}
  {{- printf "%s.%s" $values.svc (first $.Values.defaults.domains) }}
{{- end -}}
{{- /* Create and return OpenID URL Name */}}
{{- define "getOpenIDUrl" -}}
  {{- $values := index . 0 -}}
  {{- $realm := index . 1 -}}
  {{- $ := index . 2 -}}
  {{- printf "%s/%s/%s" $.Values.defaults.issuerUrl $realm $.Values.defaults.openidConfigurationUrl -}}
{{- end -}}
{{- define "authExists" -}}
  {{- $allAuthTypes := list "ui" "ui-with-strongauth" "backend" "backend-with-strongauth" "m2m" "m2m-with-token" -}}
  {{- if (index . 0) -}}
    {{- if has (index . 0) $allAuthTypes -}}
      {{- print "true" -}}
    {{- else -}}
      {{- print "false" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}