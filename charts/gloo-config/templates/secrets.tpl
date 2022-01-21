{{ range $.Values.apigw -}}
  {{- $values := dict -}}
  {{- $_ := set $values "svc" .svc -}}
  {{- $_ := set $values "servicedomain" (regexSplit " " (include "getSvcDomain" (list $values $)) -1) -}}
  {{- $_ := set $values "uiclientsecretset" false -}}
  {{- $_ := set $values "m2mclientsecretset" false -}}
  {{- range $key, $val := .routes }}
    {{- $_ := set $values "authenticationtype" $val.authenticationType -}}
    {{- $_ := set $values "authenticationconfig" $val.authenticationConfig -}}
    {{- $_ := set $values "clientid" ($val.authenticationConfig).clientId -}}
    {{- $_ := set $values "callbackpath" (default $.Values.defaults.authenticationConfig.callbackPath ($val.authenticationConfig).callbackPath) -}}
    {{- $_ := set $values "clientsecret" (include "getclientSecretRef" (list $values)) -}}

    {{- if and (or (eq "ui" $values.authenticationtype) (eq "ui-with-strongauth" $values.authenticationtype)) (not $values.uiclientsecretset) (not ($values.authenticationconfig).externalSecretClientSecretRef) -}}
---
apiVersion: 'kubernetes-client.io/v1'
kind: ExternalSecret
metadata:
  name: {{ $values.clientsecret }}
  namespace: {{ $.Release.Namespace }}
spec:
  backendType: secretsManager
      {{- if $values.authenticationconfig.externalSecretClientSecretRoleArn }}
  roleArn: {{ $values.authenticationconfig.externalSecretClientSecretRoleArn }}
      {{- end}}
  template:
    metadata:
      annotations:
        resource_kind: '*v1.Secret'
  data:
    - key: {{ $values.authenticationconfig.externalSecretClientSecretKey }}
      property: {{ $values.clientid | quote }}
      name: oauth
      {{- $_ := set $values "uiclientsecretset" true -}}
    {{ else if and (or (eq "m2m-with-token" $values.authenticationtype)) (not $values.m2mclientsecretset) (not ($values.authenticationconfig).externalSecretClientSecretRef) -}}
---
apiVersion: 'kubernetes-client.io/v1'
kind: ExternalSecret
metadata:
  name: {{ $values.clientsecret }}
  namespace: {{ $.Release.Namespace }}
spec:
  backendType: secretsManager
      {{- if $values.authenticationconfig.externalSecretClientSecretRoleArn }}
  roleArn: {{ $values.authenticationconfig.externalSecretClientSecretRoleArn }}
      {{- end}}
  data:
    - key: {{ $values.authenticationconfig.externalSecretClientSecretKey }}
      property: {{ $values.clientid | quote }}
      name: ClientCredentialsFlow
      {{- $_ := set $values "m2mclientsecretset" true -}}
    {{ end -}}
  {{ end -}}
{{ end -}}
