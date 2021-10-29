{{- range $.Values.apigw }}
  {{- $values := dict -}}
  {{- $_ := set $values "svc" .svc -}}
  {{- $_ := set $values "appname" .appName -}}
  {{- $_ := set $values "svcname" .svcName -}}
  {{- $_ := set $values "usemtls" .useMTLS -}}
  {{- $_ := set $values "serviceport" .servicePort -}}
  {{- $_ := set $values "upstreamname" (printf "%s-%s-svc-%v" $.Release.Namespace $values.svc $values.serviceport) -}}
  {{- $_ := set $values "upstreamnamespace" $.Values.defaults.upstreamNamespace -}}
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
  {{- if $values.usemtls }}
  sslConfig:
    alpnProtocols:
      - istio
    sds:
      certificatesSecretName: istio_server_cert
      clusterName: gateway_proxy_sds
      targetUri: 127.0.0.1:8234
      validationContextName: istio_validation_context
  {{- end }}
{{- end }}