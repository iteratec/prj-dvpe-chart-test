{{- /* Check if any redirects are defined */}}
{{- $redirects := dict -}}
{{- range $.Values.apigw -}}
  {{- range .routes -}}
    {{- if .httpsRedirect -}}
      {{- $_ := set $redirects "found" true -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- if $redirects.found -}}
  {{- range $key, $val := $.Values.apigw -}}
    {{- $values := dict -}}
    {{- $_ := set $values "svc" $val.svc -}}
    {{- $_ := set $values "internet" $val.internet -}}
    {{- $_ := set $values "virtualservicename" (include "getVirtualServiceName" (list (printf "%s-%s" $values.svc "http-to-https") $key)) -}}
    {{- $_ := set $values "servicedomain" (include "getSvcDomain" (list $values $) ) -}}

    {{ printf "\n---" }}
apiVersion: gateway.solo.io/v1
kind: VirtualService
metadata:
  name: {{ $values.virtualservicename }}
  namespace: {{ $.Release.Namespace }}
  labels:
      {{- if eq true $values.internet }}
    {{ $.Values.defaults.metadata.glooGateway}}: public
      {{- else }}
    {{ $.Values.defaults.metadata.glooGateway}}: private
      {{- end }}
spec:
  virtualHost:
    domains:
      - {{ $values.servicedomain }}
    routes:
      {{- range .routes }}
        {{- $_ := set $values "type" .type -}}
        {{- $_ := set $values "prefix" .prefix -}}
        {{- $_ := set $values "httpsredirect" .httpsRedirect -}}
        {{- if or (eq "ui" $values.type) (eq "ui-with-strongauth" $values.type) }}
          {{- if not $values.swaggerpathredirect }}
      - matchers:
        - prefix: /swagger-ui.html
        - prefix: /docs
        redirectAction:
          httpsRedirect: true
            {{- $_ := set $values "swaggerpathredirect" true -}}
          {{- end }}
        {{- end }}
        {{- if and ($values.httpsredirect) (not (eq "/docs" $values.prefix)) (not (eq "/swagger-ui.html" $values.prefix)) }}
      - matchers:
        - prefix: {{ $values.prefix }}
        redirectAction:
          httpsRedirect: true
        {{- end }}
        {{- if eq "/" $values.prefix -}}
          {{- $_ := set $values "rootPathExist" "" -}}
        {{- end -}}
      {{- end -}}
    {{- /* Set root prefix if not exist */}}
    {{- if not (hasKey $values "rootPathExist") }}
      - matchers:
        - prefix: /
          redirectAction:
            httpsRedirect: true
    {{- end }}
  {{- end -}}
{{- end -}}
