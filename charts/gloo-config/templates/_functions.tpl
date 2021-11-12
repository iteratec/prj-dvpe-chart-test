{{- /* Create and return AuthConfig Name */}}
{{- define "getAuthConfigName" -}}
  {{- $values := index . 0 -}}
  {{- $ext := "no-headerextension" -}}
  {{- if $values.headerextension -}}
    {{- if eq true $values.headerextension -}}
      {{- $ext = "with-headerextension" -}}
    {{- end -}}
  {{- end -}}
  {{- printf "%s-%s-%s" $values.svc $values.type $ext }}
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
  {{- $realm := index . 0 -}}
  {{- $ := index . 1 -}}
  {{- printf "%s/%s/%s" $.Values.defaults.issuerUrl $realm $.Values.defaults.openidConfigurationUrl -}}
{{- end -}}
{{- define "getIssuerUrl" -}}
  {{- $realm := index . 0 -}}
  {{- $ := index . 1 -}}
  {{- printf "%s/%s/" $.Values.defaults.issuerUrl $realm -}}
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
{{- define "getAcrValue" -}}
  {{- $strongauthlevel := index . 0 -}}
  {{- printf "strongAuth%vService" $strongauthlevel -}}
{{- end -}}