{{- range $.Values.apigw }}
  {{- $values := dict -}}
  {{- $_ := set $values "svc" .svc -}}
  {{- $_ := set $values "upstreamname" (printf "%s-%s-svc-%v" $.Release.Namespace $values.svc $.Values.defaults.service.port) -}}
  {{- $_ := set $values "upstreamnamespace" $.Values.defaults.upstreamNamespace -}}
apiVersion: gloo.solo.io/v1
kind: Upstream
metadata:
  name: {{ $values.upstreamname }}
  namespace: {{ $values.upstreamnamespace }}
spec:
  kube:
    selector:
      app: {{ $values.svc }}  # check correct app selector
    serviceName: {{ printf "%s-svc" $values.svc }}
    serviceNamespace: {{ $.Release.Namespace }}
    servicePort: {{ $.Values.defaults.service.port }}
  sslConfig:
    alpnProtocols:
      - istio
    sds:
      certificatesSecretName: istio_server_cert
      clusterName: gateway_proxy_sds
      targetUri: 127.0.0.1:8234
      validationContextName: istio_validation_context
{{- end }}