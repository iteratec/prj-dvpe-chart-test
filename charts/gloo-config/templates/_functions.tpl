{{- /* Generate AuthConfig Name */}}
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
{{- /* Generate VirtualService Name */}}
{{- define "getVirtualServiceName" -}}
  {{- printf "%s-%d" (index . 0) (index . 1) }}
{{- end -}}
{{- /* Generate Upstream Name */}}
{{- define "getUpStreamName" -}}
  {{- printf "%s-%s-svc-%v-%d" (index . 0) (index . 1) (index . 2) (index . 3) }}
{{- end -}}
{{- /* Generate Service DomainName URL */}}
{{- define "getAppUrl" -}}
  {{- $values := index . 0 -}}
  {{- $ := index . 1 -}}
  {{- printf "https://%s.%s" $values.svc (first $.Values.defaults.domains) }}
{{- end -}} 
{{- /* Generate Service Domain */}}
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
{{- /* Generate OpenID URL */}}
{{- define "getIssuerUrl" -}}
  {{- $realm := index . 0 -}}
  {{- $ := index . 1 -}}
  {{- printf "%s/%s/" $.Values.defaults.issuerUrl $realm -}}
{{- end -}}
{{- /* Check AuthConfig */}}
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
{{- /* Generate Strongauth ACR Value */}}
{{- define "getAcrValue" -}}
  {{- $strongauthlevel := index . 0 -}}
  {{- printf "strongAuth%vService" $strongauthlevel -}}
{{- end -}}