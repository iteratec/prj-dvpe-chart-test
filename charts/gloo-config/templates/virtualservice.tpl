{{- range $key, $val := $.Values.apigw -}}
  {{- $values := dict -}}
  {{- $_ := set $values "svc" $val.svc -}}
  {{- $_ := set $values "internet" $val.internet -}}
  {{- $_ := set $values "cors" $val.cors -}}
  {{- $_ := set $values "headermanipulation" $val.headerManipulation -}}
  {{- $_ := set $values "upstreamname" (printf "%s-%s-svc-%v" $.Release.Namespace $values.svc $.Values.defaults.service.port) -}}
  {{- $_ := set $values "virtualservicename" (include "getVirtualServiceName" (list $values.svc $key)) -}}
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
  sslConfig:
    secretRef:
      name: {{ $.Values.defaults.sslConfig.secretRef }}
      namespace: {{ $.Release.Namespace }}
    sniDomains:
      - {{ $values.servicedomain }}
  virtualHost:
    domains:
      - {{ $values.servicedomain }}
      {{- /* TODO: should it be always included, or only for UI services ? */}}
    options:
      {{- if $values.headermanipulation }}
      headerManipulation:
        responseHeadersToAdd:
        {{ range $k, $v := $values.headermanipulation -}}
          - header:
            key: {{ $v.header.key }}
            value: {{ $v.header.value }}
        {{ end -}}
      {{- end -}}
      {{- if $values.cors }} {{/* TODO: Backend only */}}
      cors:
        allowCredentials: {{ default $.Values.defaults.cors.allowCredentials $values.cors.allowCredentials }}
        {{ if $values.cors.allowHeaders -}}
        allowHeaders:
          {{- range $values.cors.allowHeaders }}
          - {{ . }}
          {{- end }}
        {{ end -}}
        {{ if $values.cors.allowMethods -}}
        allowMethods:
          {{- range $values.cors.allowMethods }}
          - {{ . }}
          {{- end }}
        {{ end -}}
        {{ if $values.cors.allowOrigin -}}
        allowOrigin:
          {{- range $values.cors.allowOrigins }}
          - {{ . | quote }}
          {{- end }}
        {{ end -}}
        {{ if $values.cors.allowOriginRegex -}}
        allowOriginRegex:
          {{- range $values.cors.allowOriginRegex }}
          - {{ . | replace "." "[.]" | replace "://" "://([a-zA-Z0-9]+[.-])*[a-zA-Z0-9]+[.]" | quote }}
          {{- end }}
        {{ end -}}
        {{ if $values.cors.exposeHeaders -}}
        exposeHeaders:
          {{- range $values.cors.exposeHeaders }}
          - {{ . }}
          {{- end }}
        {{ end -}}
        maxAge: {{ default $.Values.defaults.cors.maxAge $values.cors.maxAge }}
    {{- end }}
    routes:
    {{- range .routes }}
        {{- $_ := set $values "prefix" .prefix -}}
        {{- $_ := set $values "redirect" .redirect -}}
        {{- $_ := set $values "type" .type -}}
        {{- $_ := set $values "clientid" .clientId  -}}
        {{- $_ := set $values "callbackPath" .callbackPath -}}
        {{- $_ := set $values "headerextension" .headerExtension -}}
        {{- $_ := set $values "authconfigname" (include "getAuthConfigName" (list $values.svc $values.type $values.headerextension)) -}}

{{- /*  TODO:  umleitung zu swagger */}}
{{- /* 
      {{- if and .Values.gloo.virtualservice.spec.virtualHost.routes.swagger.enabled .Values.gloo.virtualservice.spec.virtualHost.routes.swagger.alternativePath }}
      - matchers:
          - prefix: {{ .Values.gloo.virtualservice.spec.virtualHost.routes.swagger.alternativePath }}
        redirectAction:
          pathRedirect: {{ .Values.gloo.virtualservice.spec.virtualHost.routes.swagger.path }}
      {{- end }}
*/}}
      {{- if $values.prefix }}
      - matchers:
        - prefix: {{ $values.prefix }}
          routeAction:
          single:
            upstream:
              name: {{ $values.upstreamname }}
              namespace: {{ $.Release.Namespace }}
        {{- if eq "true" (include "authExists" (list $values.type)) }}
          options:
            extauth:
              configRef:
                name: {{ $values.authconfigname }}
                namespace: {{ $.Release.Namespace }}
        {{- end -}}
      {{- end }}
      {{- if $values.callbackPath }}
      - matchers:
        - prefix: {{ $values.callbackPath }}
          routeAction:
            single:
              upstream:
                name:  {{ $values.upstreamname }} 
                namespace: {{ $.Release.Namespace }}
        {{- if $values.type }}
          options:
            extauth:
              configRef:
                name: {{ $values.authconfigname }}
                namespace: {{ $.Release.Namespace }}
        {{- end }}
      {{- end }}
      {{- if eq "/" $values.prefix -}}
        {{- $_ := set $values "rootPathExist" "" -}}
      {{- end -}}
  {{- end -}}
  {{- /* Set root prefix if not exist */}}
  {{- if not (hasKey $values "rootPathExist") }}
      - matchers:
        - prefix: /
          routeAction:
          single:
            upstream:
              name: {{ $values.upstreamname }}
              namespace: {{ $.Release.Namespace }}
        {{- if $values.type }}
          options:
            extauth:
              configRef:
                name: {{ $values.authconfigname }}
                namespace: {{ $.Release.Namespace }}
        {{- end }}
  {{- end }}
{{- end -}}

{{- /* TODO: http-to-https redirect 
---
apiVersion: gateway.solo.io/v1
kind: VirtualService
metadata:
  name: {{ $serviceName }}-http-to-https
  namespace: {{ .Release.Namespace }}
spec:
  virtualHost:
    domains:
      - {{ .Values.gloo.virtualservice.spec.virtualHost.domains }}
    routes:
      - matchers:
        {{- if .Values.gloo.virtualservice.spec.virtualHost.routes.callbackUrlPath }}
        - prefix: /
        {{- else }}
        - prefix: {{ .Values.gloo.virtualservice.spec.virtualHost.routes.swagger.path }}
        {{- if .Values.gloo.virtualservice.spec.virtualHost.routes.swagger.alternativePath }}
        - prefix: {{ .Values.gloo.virtualservice.spec.virtualHost.routes.swagger.alternativePath }}
        {{- end }}
        {{- end }}
        redirectAction:
          hostRedirect: {{ .Values.gloo.virtualservice.spec.virtualHost.domains }}
          httpsRedirect: true
{{- end }}

{{- end }}

*/}}