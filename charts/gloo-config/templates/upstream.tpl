{{ range $key, $val := $.Values.apigw -}}
  {{- $values := dict -}}
  {{- $_ := set $values "svc" $val.svc -}}
  {{- $_ := set $values "appname" $val.appName -}}
  {{- $_ := set $values "svcname" $val.svcName -}}
  {{- $_ := set $values "serviceport" (default $.Values.defaults.service.port $val.servicePort)  -}}
  {{- $_ := set $values "upstreamname" (include "getUpStreamName" (list $values)) -}}
  {{- $_ := set $values "upstreamnamespace" $.Release.Namespace -}}
---
apiVersion: gloo.solo.io/v1
kind: Upstream
metadata:
  name: {{ $values.upstreamname }}
  namespace: {{ $values.upstreamnamespace }}
spec:
  kube:
    selector:
      app: {{ default $values.svc $values.appname }}
    serviceName: {{ default (printf "%s-svc" $values.svc) $values.svcname }}
    serviceNamespace: {{ $.Release.Namespace }}
    servicePort: {{ $values.serviceport }}
  sslConfig:
    alpnProtocols:
      - istio
    sds:
      certificatesSecretName: istio_server_cert
      clusterName: gateway_proxy_sds
      targetUri: 127.0.0.1:8234
      validationContextName: istio_validation_context
{{ end -}}