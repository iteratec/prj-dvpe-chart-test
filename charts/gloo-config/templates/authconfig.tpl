{{- range $.Values.apigw }}
  {{- $values := dict -}}
  {{- $_ := set $values "svc" .svc -}}
  {{- $_ := set $values "internet" .internet -}}
  {{- $_ := set $values "strongauthlevel" .strongAuthLevel -}}
  {{- range $key, $val := .routes }}
    {{- $_ := set $values "prefix" $val.prefix -}}
    {{- $_ := set $values "redirect" $val.redirect -}}
    {{- $_ := set $values "type" $val.type -}}
    {{- $_ := set $values "clientid" $val.clientId -}}
    {{- $_ := set $values "callbackpath" (default $.Values.defaults.callbackPath $val.callbackPath) -}}
    {{- $_ := set $values "clientsecret" $val.clientSecret -}}
    {{- $_ := set $values "headerextension" $val.headerExtension -}}
    {{- $_ := set $values "allowedclientids" $val.allowedClientIds -}}
    {{- $_ := set $values "sessioncachename" (default $.Values.defaults.extauth.session.cacheName $val.sessionCacheName) -}}
    {{- $_ := set $values "authpluginmode" $val.authPluginMode -}}
    {{- $_ := set $values "authconfigname" (include "getAuthConfigName" (list $values)) -}}
    {{- $_ := set $values "appurl" (include "getAppUrl" (list $values $)) -}}
    {{- $_ := set $values "openidurl" (include "getOpenIDUrl" (list $.Values.defaults.realms.default $)) -}}
    {{- $_ := set $values "issuerurl" (include "getIssuerUrl" (list $.Values.defaults.realms.default $)) -}}

    {{ printf "\n---\n" }}
    {{- if eq "ui" $values.type -}}
      {{ include "auth_ui" (list $values $) }}

    {{- else if eq "ui-with-strongauth" $values.type -}}
      {{- $_ := set $values "acrvalue" (include "getAcrValue" (list $values.strongauthlevel)) -}}
      {{- if empty $values.strongauthlevel -}}
        {{- fail "require strongAuthLevel in svc definition to use strongauth" -}}
      {{- end -}}
      {{ include "auth_ui-with-strongauth" (list $values $) }}

    {{- else if eq "backend" $values.type -}}
      {{ include "auth_backend" (list $values $) }}

    {{- else if eq "backend-with-strongauth" $values.type -}}
      {{- if empty $values.strongauthlevel -}}
        {{- fail "require strongAuthLevel in svc definition to use strongauth" -}}
      {{- end -}}
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
