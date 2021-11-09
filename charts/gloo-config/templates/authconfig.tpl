{{- range $.Values.apigw }}
  {{- $values := dict -}}
  {{- $_ := set $values "svc" .svc -}}
  {{- $_ := set $values "internet" .internet -}}
  {{- range .routes }}
    {{- $_ := set $values "prefix" .prefix -}}
    {{- $_ := set $values "redirect" .redirect -}}
    {{- $_ := set $values "type" .type -}}
    {{- $_ := set $values "clientid" (.clientId | default "") -}}
    {{- $_ := set $values "callbackpath" .callbackPath -}}
    {{- $_ := set $values "headerextension" .headerExtension -}}
    {{- $_ := set $values "allowedclientids" .allowedClientIds -}}
    {{- $_ := set $values "clientsecret" .clientSecret -}}
    {{- $_ := set $values "authconfigname" (include "getAuthConfigName" (list $values)) -}}
    {{- $_ := set $values "appurl" (include "getAppUrl" (list $values $)) -}}
    {{- $_ := set $values "openidurl" (include "getOpenIDUrl" (list $.Values.defaults.realms.default $)) -}}
    {{- $_ := set $values "issuerurl" (include "getIssuerUrl" (list $.Values.defaults.realms.default $)) -}}

    {{ printf "\n---\n" }}
    {{- if eq "ui" $values.type -}}
      {{ include "auth_ui" (list $values $) }}

    {{- else if eq "ui-with-strongauth" $values.type -}}
      {{ include "auth_ui-with-strongauth" (list $values $) }}

    {{- else if eq "backend" $values.type -}}
      {{ include "auth_backend" (list $values $) }}

    {{- else if eq "backend-with-strongauth" $values.type -}}
      {{ include "auth_backend-with-strongauth" (list $values $) }}

    {{- else if eq "m2m" $values.type -}}
      {{- /* Use M2M Realm and create OpenID URL*/}}
      {{- $_ := set $values "openidurl" (include "getOpenIDUrl" (list $.Values.defaults.realms.m2m $)) -}}
      {{ include "auth_m2m" (list $values $) }}

    {{- else if eq "m2m-with-token" $values.type -}}
      {{- /* Use M2M Realm and create OpenID URL*/}}
      {{- $_ := set $values "openidurl" (include "getOpenIDUrl" (list $.Values.defaults.realms.m2m $)) -}}
      {{ include "auth_m2m-with-token" (list $values $) }}

    {{- else -}}
    {{- end -}}

  {{- end -}}
{{- end -}}
