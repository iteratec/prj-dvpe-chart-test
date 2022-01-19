{{- /* Get Domain Informations 

### Description: 

Helper template function to return a specific domain information like tld or subdomain based on parameter

### Parameters: 

- selector (string)
- global values (interface)
  
### Return:

Domain Name (string)

### Example:

{{ $var := (include "getDomainInfo" (list $getPrivateDomain $)) }}
{{ $var_subdomain := (include "getDomainInfo" (list $getPublicSubDomainInt $)) }}
{{ print $var }}
-> [.tld1.de .tld2.com] 
{{ print $var_subdomain }}
-> [.public.prod] 

*/}}
{{- define "getDomainInfo" -}}
  {{- $selector := index . 0 -}}
  {{- $ := index . 1 -}}

  {{- $data := dict -}}
  {{- $_ := set $data "private_domains" (default (list ".iteratec.de" ".iteratec.com") ($.Values.defaults.domains).private.topLevel) -}}
  {{- $_ := set $data "public_domains" (default (list ".iteratec.io") ($.Values.defaults.domains).public.topLevel) -}}
  {{- $_ := set $data "private_subdomain_prod" (default ".private.prod" ($.Values.defaults.domains).private.subDomain.production) -}}
  {{- $_ := set $data "private_subdomain_int" (default ".private.int" ($.Values.defaults.domains).private.subDomain.integration) -}}
  {{- $_ := set $data "private_subdomain_dev" (default ".private.dev" ($.Values.defaults.domains).private.subDomain.development) -}}
  {{- $_ := set $data "public_subdomain_prod" (default ".prod" ($.Values.defaults.domains).public.subDomain.production) -}}
  {{- $_ := set $data "public_subdomain_int" (default ".int" ($.Values.defaults.domains).public.subDomain.production) -}}

  {{- if eq "getPrivateDomains" $selector -}}
    {{- range $data.private_domains -}}
      {{- printf "%v " . -}}
    {{- end -}}
  {{- else if eq "getPublicDomains" $selector -}}
    {{- range $data.public_domains -}}
      {{- printf "%v " . -}}
    {{- end -}}
  {{- else if eq "getPublicSubDomainProd" $selector -}}
    {{- print $data.public_subdomain_prod -}}
  {{- else if eq "getPublicSubDomainInt" $selector -}}  
    {{- print $data.public_subdomain_int -}}
  {{- else if eq "getPrivateSubDomainProd" $selector -}}
    {{- print $data.private_subdomain_prod -}}
  {{- else if eq "getPrivateSubDomainInt" $selector -}}
    {{- print $data.private_subdomain_int -}}
  {{- else if eq "getPrivateSubDomainDev" $selector -}}
    {{- print $data.private_subdomain_dev -}}
  {{- end -}}
{{- end -}}


{{- /* Generate AuthConfig Name 

### Description: 

Create and return the name of AuthConfig resource based on Service name (svc), headerextentions authenticationType

### Parameters: 

- values (dict)
- global values (interface)
  
### Return:

AuthConfigName (string)

### Example:

{{ $_ := set $dict "svc" "myserver" }}
{{ $var := (include "getAuthConfigName" (list $dict 0)) }}
{{ print $var }}
-> myservice-0

*/}}
{{- define "getAuthConfigName" -}}
  {{- $values := index . 0 -}}
  {{- $index := index . 1 -}}
  {{- printf "%s-%d" $values.svc $index }}
{{- end -}}

{{- /* Generate VirtualService Name 

### Description: 

Create and return the name of VirtualService resource based on Parameter one and Parameter two

### Parameters: 

- param1 (string)
- param2 (int)
  
### Return:

value (string)

### Example:

{{ $var := (include "getVirtualServiceName" (list "svc" 1)) }}
{{ print $var }}
-> svc-1 

*/}}
{{- define "getVirtualServiceName" -}}
  {{- printf "%s-%d" (index . 0) (index . 1) }}
{{- end -}}

{{- /* Generate Upstream Name 

### Description: 

Create and return the name of Upstream resource based on Parameters 

### Parameters: 

- param1 (string)
- param2 (string)
- param3 (string)
- param4 (int)

### Return:

value (string)

### Example:

{{ $var := (include "getUpStreamName" (list "backend" "upstream" "int" 2)) }}
{{ print $var }}
-> backend-upstream-svc-int-2 

*/}}
{{- define "getUpStreamName" -}}
  {{- printf "%s-%s-svc-%v" (index . 0) (index . 1) (index . 2) }}
{{- end -}}

{{- /* Generate AuthConfig AppUrl 

### Description: 

Create and return the url for authconfig value oauth2.oidcAuthorizationCode.appUrl based on available service domains
The template function will always use first domain from service domain list if multiple domains are configured

### Parameters: 

- values (dict)
- global values (interface)

### Return:

value (string)

### Example:

{{ $var := (include "getAppUrl" (list $dict $)) }}
{{ print $var }}
-> https://

*/}}
{{- define "getAppUrl" -}}
  {{- $values := index . 0 -}}
  {{- $ := index . 1 -}}
  {{- printf "https://%s" (first (regexSplit " " (include "getSvcDomain" (list $values $)) -1 )) }}
{{- end -}} 

{{- /* Generate Service Domain (FQDN)

### Description: 

Helper template function to generate the fulled qualified domain name based on multiple values (env and internet)
The return string will contain a separator char as suffix (whitespace) !
To handle the return string in loop iterations (range, ...), use regexSplit function (see Example).

### Parameters: 

- values (dict)
- global values (interface)

### Return:

value (string)

### Example:

{{ $_ := set $dict "svc" "myservice" }}
{{ $_ := set $dict "internet" true }}
{{ $_ := set $dict "env" "prod" }}
{{ $var := (regexSplit " " (include "getSvcDomain" (list $dict $)) -1) }}
{{ print $var }}
-> [myservice.private.prod.iteratec.com myservice.private.prod.iteratec.de myservice.private.prod.iteratec.io]

*/}}
{{- define "getSvcDomain" -}}
  {{- $values := index . 0 -}}
  {{- $ := index . 1 -}}
  {{- $s := dict -}}
  {{- if eq "prod" $.Values.defaults.env -}}
    {{- if $values.internet -}}
      {{- $_ := set $s "subdomain" (include "getDomainInfo" (list "getPublicSubDomainProd" $)) -}}
    {{- else -}}
      {{- $_ := set $s "subdomain" (include "getDomainInfo" (list "getPrivateSubDomainProd" $)) -}}
    {{- end -}}
  {{- else if eq "int" $.Values.defaults.env -}}
    {{- if $values.internet -}}
      {{- $_ := set $s "subdomain" (include "getDomainInfo" (list "getPublicSubDomainInt" $)) -}}
    {{- else -}}
      {{- $_ := set $s "subdomain" (include "getDomainInfo" (list "getPrivateSubDomainInt" $)) -}}
    {{- end -}}
  {{- else if eq "dev" $.Values.defaults.env -}}
    {{- if $values.internet -}}
      {{- $_ := set $s "subdomain" (include "getDomainInfo" (list "getPublicSubDomainDev" $)) -}}
    {{- else -}}
      {{- $_ := set $s "subdomain" (include "getDomainInfo" (list "getPrivateSubDomainDev" $)) -}}
    {{- end -}}
  {{- end -}}

  {{- $_ := set $s "publicdomains" (regexSplit " " (include "getDomainInfo" (list "getPublicDomains" $)) -1) -}}
  {{- $_ := set $s "privatedomains" (regexSplit " " (include "getDomainInfo" (list "getPrivateDomains" $)) -1) -}}
  

  {{- if $values.internet -}}
    {{- range $s.publicdomains -}}
      {{- if . -}}
        {{- printf "%v%v%v " $values.svc (default "" $s.subdomain) . -}}
      {{- end -}}
    {{- end -}}
  {{- else -}}
    {{- range $s.privatedomains -}}
      {{- if . -}}
        {{- printf "%v%v%v " $values.svc (default "" $s.subdomain) . -}}
      {{- end -}}
    {{- end -}} 
  {{- end -}}  
{{- end -}}

{{- /* Generate OpenID URL

### Description: 

Create and return OpenID URL Name

### Parameters: 

- realm (string)
- global values (interface)

### Return:

value (string)

### Example:

[in values.yaml]
defaults:
  issuerUrl: https://oidc.iteratec.com/realms/root/realms
  openidConfigurationUrl: .well-known/openid-configuration

{{ $var := (include "getOpenIDUrl" (list "myRealm" $)) }}
{{ print $var }}
-> https://oidc.iteratec.com/realms/root/realms/myRealm/.well-known/openid-configuration

*/}}
{{- define "getOpenIDUrl" -}}
  {{- $realm := index . 0 -}}
  {{- $ := index . 1 -}}
  {{- printf "%s/%s/%s" $.Values.defaults.issuerUrl $realm $.Values.defaults.openidConfigurationUrl -}}
{{- end -}}

{{- /* Generate Issuer URL

### Description: 

Create and return Issuer URL Name

### Parameters: 

- realm (string)
- global values (interface)

### Return:

value (string)

### Example:

[in values.yaml]
defaults:
  issuerUrl: https://oidc.iteratec.com/realms/root/realms

{{ $var := (include "getIssuerUrl" (list "myRealm" $)) }}
{{ print $var }}
-> https://oidc.iteratec.com/realms/root/realms/myRealm/

*/}}
{{- define "getIssuerUrl" -}}
  {{- $realm := index . 0 -}}
  {{- $ := index . 1 -}}
  {{- printf "%s/%s/" $.Values.defaults.issuerUrl $realm -}}
{{- end -}}

{{- /* Check AuthConfig

### Description: 

Check parameter for existing authconfig name

### Parameters: 

- authconfig type (string)

### Return:

value (string)

### Example:

{{ $var := (include "authExists" "backend") }}
{{ print $var }}
-> "true"

*/}}
{{- define "authExists" -}}
  {{- $allAuthTypes := list "ui" "ui-with-strongauth" "backend" "backend-with-strongauth" "m2m" "m2m-with-token" -}}
  {{- if (index . 0) -}}
    {{- if has (index . 0) $allAuthTypes -}}
      {{- print "true" -}}
    {{- else -}}
      {{- print "false" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- /* Generate Strongauth ACR value

### Description: 

Generate and return Strongauth ACR value

### Parameters: 

- strongauthlevel (string)

### Return:

value (string)

### Example:

{{ $var := (include "getAcrValue" "2403") }}
{{ print $var }}
-> "strongAuth2403Service"

*/}}
{{- define "getAcrValue" -}}
  {{- $strongauthlevel := index . 0 -}}
  {{- printf "strongAuth%vService" $strongauthlevel -}}
{{- end -}}
