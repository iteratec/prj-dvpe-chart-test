{{ range $key, $val := $.Values.apigw -}}
  {{- $values := dict -}}
  {{- $_ := set $values "svc" $val.svc -}}
  {{- $_ := set $values "internet" $val.internet -}}
  {{- $_ := set $values "csrf" $val.csrf -}}
  {{- $_ := set $values "cors" $val.cors -}}
  {{- $_ := set $values "headermanipulation" $val.headerManipulation -}}
  {{- $_ := set $values "rootprefix" ($val.rootPrefix | toString) -}}
  {{- $_ := set $values "swaggerprefix" ($val.swaggerPrefix | toString) -}}
  {{- $_ := set $values "serviceport" (default $.Values.defaults.service.port $val.servicePort) -}}
  {{- $_ := set $values "sslconfig" (default $.Values.defaults.sslConfig $val.sslConfig) -}}
  {{- $_ := set $values "virtualservicename" $values.svc -}}
  {{- $_ := set $values "servicedomain" (regexSplit " " (include "getSvcDomain" (list $values $)) -1) -}}
---
apiVersion: gateway.solo.io/v1
kind: VirtualService
metadata:
  name: {{ $values.virtualservicename }}
  namespace: {{ $.Release.Namespace }}
  labels:
    {{- if $values.internet }}
      {{ $.Values.defaults.metadata.glooGateway }}: public
    {{- else }}
      {{ $.Values.defaults.metadata.glooGateway }}: private
    {{- end }}
spec:
  sslConfig:
    parameters:
      minimumProtocolVersion: {{ $values.sslconfig.minTlsVersion }}
    secretRef:
      {{- if $values.sslconfig.useCustomIssuer }}
      name: {{ $values.sslconfig.secretRef }}
      namespace: {{ $values.sslconfig.secretRefNamespace }}
      {{- else if $values.internet }}
      name: gloo-public-tls
      namespace: "gloo-system"
      {{- else }}
      name: {{ $values.svc }}-private-tls-by-issuer
      namespace: {{ $.Release.Namespace -}}
      {{- end }}
    sniDomains:
      {{- range $values.servicedomain }}
        {{- if . }}
      - {{ . }}
        {{- end }}
      {{- end }}
  virtualHost:
    domains: 
      {{- range $values.servicedomain }}
        {{- if . }}
      - {{ . }}
        {{- end }}
      {{- end }}
    options:
      {{- if $values.headermanipulation }}
      headerManipulation:
        responseHeadersToAdd:
        {{- range $k, $v := $values.headermanipulation }}
          - header:
              key: {{ $v.header.key }}
              value: {{ $v.header.value }}
        {{- end }}
      {{- end }}
      {{- if $values.csrf }}
      csrf:
        additionalOrigins:
          {{- range $values.csrf.allowSubdomain }}
          - suffix: {{ regexReplaceAll "^.*://" . "" }}
          {{- end }}
        filterEnabled:
          defaultValue:
            numerator: 100
      {{- end}}
      {{- if $values.cors }} 
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
    {{- range $key, $val := .routes }}
        {{- $_ := set $values "prefix" $val.prefix -}}
        {{- $_ := set $values "authenticationtype" $val.authenticationType -}}
        {{- $_ := set $values "clientid" ($val.authenticationConfig).clientId  -}}
        {{- $_ := set $values "callbackPath" (default $.Values.defaults.authenticationConfig.callbackPath ($val.authenticationConfig).callbackPath) -}}
        {{- $_ := set $values "headerextension" ($val.authenticationConfig).headerExtension -}}
        {{- $_ := set $values "upstream" $val.upstream -}}
        {{- $_ := set $values "timeout" (default $.Values.defaults.timeout $val.timeout) -}}
        {{- $_ := set $values "authconfigname" (include "getAuthConfigName" (list $values $key)) -}}

        {{- if $values.upstream -}}
          {{- $_ := set $values "upstreamname" $values.upstream.name -}}
          {{- $_ := set $values "upstreamnamespace" $values.upstream.namespace -}}
        {{- else -}}
          {{- $_ := set $values "upstreamname" (include "getUpStreamName" (list $.Release.Namespace $values.svc $values.serviceport)) -}}
          {{- $_ := set $values "upstreamnamespace" $.Release.Namespace -}}
        {{- end -}}

        {{- /* Set swagger redirect rule for ui auth flows */}}
        {{- if or (eq "backend" $values.authenticationtype) (eq "backend-with-strongauth" $values.authenticationtype) (eq "m2m" $values.authenticationtype) (eq "m2m-with-token" $values.authenticationtype) }}
          {{- if and (not $values.swaggerpathredirect) (or (eq $values.swaggerprefix "true") (eq $values.swaggerprefix "<nil>")) }}
      - matchers:
        - prefix: /docs
        redirectAction:
          pathRedirect: /swagger-ui.html
            {{- $_ := set $values "swaggerpathredirect" true -}}
          {{- end }}
        {{- end }}

      {{- /* Define callback path prefix */}}
      {{- if or (eq "ui" $values.authenticationtype) (eq "ui-with-strongauth" $values.authenticationtype) }}
      - matchers:
        - prefix: {{ $values.callbackPath }}
        routeAction:
          single:
            upstream:
              name:  {{ $values.upstreamname }} 
              namespace: {{ $values.upstreamnamespace }}
        {{- if $values.authenticationtype }}
        options:
          timeout: {{ $values.timeout }}
          extauth:
            configRef:
              name: {{ $values.authconfigname }}
              namespace: {{ $.Release.Namespace }}
        {{- end }}
      {{- end }}

      {{- /* Define path prefix if defined */}}
      {{- if $values.prefix }}
      - matchers:
        - prefix: {{ $values.prefix }}
        routeAction:
          single:
            upstream:
              name: {{ $values.upstreamname }}
              namespace: {{ $values.upstreamnamespace }}
        {{- if eq "true" (include "authExists" (list $values.authenticationtype)) }}
        options:
          timeout: {{ $values.timeout }}
          extauth:
            configRef:
              name: {{ $values.authconfigname }}
              namespace: {{ $.Release.Namespace }}
        {{- end -}}
      {{- end }}

      {{- if eq "/" $values.prefix -}}
        {{- $_ := set $values "rootPathExist" "" -}}
      {{- end -}}
  {{- end -}}
  {{- /* Set root prefix if not exist */}}
  {{- if and (not (hasKey $values "rootPathExist")) (or (eq $values.rootprefix "true") (eq $values.rootprefix "<nil>")) }}
      - matchers:
        - regex: '^/([^/\s]|$).*'
        routeAction:
          single:
            upstream:
              name: {{ $values.upstreamname }}
              namespace: {{ $values.upstreamnamespace }}
        {{- if $values.authenticationtype }}
        options:
          timeout: {{ $values.timeout }}
          extauth:
            configRef:
              name: {{ $values.authconfigname }}
              namespace: {{ $.Release.Namespace }}
        {{- end }}
  {{- end }}
{{ end -}}