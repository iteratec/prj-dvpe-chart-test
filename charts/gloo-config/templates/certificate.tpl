{{ range $.Values.apigw -}}
  {{- $values := dict -}}
  {{- $_ := set $values "svc" .svc -}}
  {{- $_ := set $values "internet" .internet -}}
  {{- $_ := set $values "sslconfig" $.Values.defaults.sslConfig -}}
  {{- $_ := set $values "servicedomain" (regexSplit " " (include "getSvcDomain" (list $values $)) -1) -}}

  {{- if and (not $values.internet) (not $values.sslconfig.useCustomIssuer) }}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: {{ $values.svc }}-certificate-by-issuer
spec:
  commonName: {{ first $values.servicedomain }}
  secretName: {{ $values.svc }}-private-tls-by-issuer
  issuerRef:
    name: wadtfy-certificate-issuer
    group: {{ $values.sslconfig.certificate.issuergroup }}
    kind: Issuer
  subject:
    organizations:
      - {{ $values.sslconfig.certificate.organization }}
    countries:
      - {{ $values.sslconfig.certificate.country }}
    localities:
      - {{ $values.sslconfig.certificate.location }}
    provinces:
      - {{ $values.sslconfig.certificate.province }}
    organizationalUnits:
      - {{ $values.sslconfig.certificate.organizationalUnit }}
    dnsNames:
    {{- range $values.servicedomain }}
      {{- if . }}
      - {{ . }}
      {{- end }}
    {{- end }}
    emailAddresses:
    {{- range $values.sslconfig.certificate.emailAddresses }}
      - {{ . }}
    {{- end }}
  {{- end }}
{{- end }}
