{{ range $.Values.apigw -}}
  {{- $values := dict -}}
  {{- $_ := set $values "svc" .svc -}}
  {{- $_ := set $values "internet" .internet -}}
  {{- $_ := set $values "strongauthlevel" .strongAuthLevel -}}
  {{- $_ := set $values "passthru" .passthru -}}
  {{- $_ := set $values "servicedomain" (regexSplit " " (include "getSvcDomain" (list $values $)) -1) -}}

  {{- range $key, $val := .routes }}
    {{- $_ := set $values "prefix" $val.prefix -}}
    {{- $_ := set $values "authenticationtype" $val.authenticationType -}}
    {{- $_ := set $values "clientid" ($val.authenticationConfig).clientId -}}
    {{- $_ := set $values "callbackpath" (default $.Values.defaults.authenticationConfig.callbackPath ($val.authenticationConfig).callbackPath) -}}
    {{- $_ := set $values "authenticationconfig" $val.authenticationConfig -}}
    {{- $_ := set $values "clientsecret" (include "getclientSecretRef" (list $values)) -}}
    {{- $_ := set $values "headerextension" ($val.authenticationConfig).headerExtension -}}
    {{- $_ := set $values "allowedclientids" ($val.authenticationConfig).allowedClientIds -}}
    {{- $_ := set $values "cookiename" (default $.Values.defaults.authenticationConfig.redis.cookieName ((($val.authenticationConfig).redis).cookieName)) -}}
    {{- $_ := set $values "cookietimeout" (default $.Values.defaults.authenticationConfig.session.cookieTimeout ((($val.authenticationConfig).session).cookieTimeout )) -}}
    {{- $_ := set $values "authpluginmode" ($val.authenticationConfig).authPluginMode -}}
    {{- $_ := set $values "authconfigname" (include "getAuthConfigName" (list $values $key)) -}}
    {{- $_ := set $values "appurl" (include "getAppUrl" (list $values $)) -}}
    {{- $_ := set $values "openidurl" (include "getOpenIDUrl" (list $.Values.defaults.realms.default $)) -}}
    {{- $_ := set $values "issuerurl" (include "getIssuerUrl" (list $.Values.defaults.realms.default $)) -}}

    {{- if eq "ui" $values.authenticationtype -}}
      {{ include "auth_ui" (list $values $) }}

    {{- else if eq "ui-with-strongauth" $values.authenticationtype -}}
      {{- $_ := set $values "acrvalue" (include "getAcrValue" (list $values.strongauthlevel)) -}}
      {{- if empty $values.strongauthlevel -}}
        {{- fail "require strongAuthLevel in svc definition to use strongauth" -}}
      {{- end -}}
      {{ include "auth_ui-with-strongauth" (list $values $) }}

    {{- else if eq "backend" $values.authenticationtype -}}
      {{ include "auth_backend" (list $values $) }}

    {{- else if eq "backend-with-strongauth" $values.authenticationtype -}}
      {{- if empty $values.strongauthlevel -}}
        {{- fail "require strongAuthLevel in svc definition to use strongauth" -}}
      {{- end -}}
      {{ include "auth_backend-with-strongauth" (list $values $) }}

    {{- else if eq "m2m" $values.authenticationtype -}}
      {{- /* Use M2M Realm and create OpenID URL*/}}
      {{- $_ := set $values "openidurl" (include "getOpenIDUrl" (list $.Values.defaults.realms.m2m $)) -}}
      {{ include "auth_m2m" (list $values $) }}

    {{- else if eq "m2m-with-token" $values.authenticationtype -}}
      {{- /* Use M2M Realm and create OpenID URL*/}}
      {{- $_ := set $values "openidurl" (include "getOpenIDUrl" (list $.Values.defaults.realms.m2m $)) -}}
      {{ include "auth_m2m-with-token" (list $values $) }}

    {{- else -}}
    {{- end -}}

  {{- end -}}
{{ end -}}
