# saml-proxy ![build](https://travis-ci.com/lyang/saml-proxy.svg?branch=master) [![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE) [![Maintainability](https://api.codeclimate.com/v1/badges/58cdb58ef538f551da7a/maintainability)](https://codeclimate.com/github/lyang/saml-proxy/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/58cdb58ef538f551da7a/test_coverage)](https://codeclimate.com/github/lyang/saml-proxy/test_coverage)
A simple saml proxy for SSO integration

## What is SAML
> Security Assertion Markup Language is an open standard for exchanging authentication and authorization data between parties, in particular, between an identity provider and a service provider. SAML is an XML-based markup language for security assertions (statements that service providers use to make access-control decisions).

## Why use SAML
> An important use case that SAML addresses is web-browser single sign-on (SSO). Single sign-on is relatively easy to accomplish within a security domain (using cookies, for example) but extending SSO across security domains is more difficult and resulted in the proliferation of non-interoperable proprietary technologies. The SAML Web Browser SSO profile was specified and standardized to promote interoperability.

## What is `saml-proxy`?
TLDR: Like [oauth2-proxy](https://github.com/oauth2-proxy/oauth2-proxy), but for SAML. Typical SAML SSO providers include `PingId`, `Okta`, `OneLogin` etc.

## Why use `saml-proxy`?
So you can easily add SSO protection without modifying existing applications.

## How does it work?
TLDR:
```nginx
server{
  ...
  location / {
    auth_request /auth;
    auth_request_set $saml_email $upstream_http_saml_email;
    proxy_set_header Saml-Email $saml_email;
    error_page 401 = /start?redirect=$request_uri;
    proxy_pass http://app:4567;
  }

  location /auth {
    internal;
    proxy_pass http://saml-proxy:9292;
  }

  location /start {
    proxy_pass http://saml-proxy:9292;
  }

  location /consume {
    proxy_pass http://saml-proxy:9292;
  }
}
```
Sequence Diagram:
![sequence-diagram](https://puml-demo.herokuapp.com/raw/https%3A%2F%2Fraw.githubusercontent.com%2Flyang%2Fsaml-proxy-example%2Fmaster%2Fsequence-diagram.puml)

## I want to see it in action
Take a look at [saml-proxy-example](https://github.com/lyang/saml-proxy-example)

## How do I configure it for my production setup

### Via environment variables

#### Server
| Name | Default | Comment |
|------|---------|---------|
| `RACK_ENV` | `development` | |
| `PORT` | `9292` | |
| `PUMA_MAX_THREADS` | `5` | |

#### SAML
| Name | Required | Comment |
|------|----------|---------|
| `SAML_IDP_METADATA` | `True` | Path to local file or remote url |
| `SAML_SP_ENTITY_ID` | `True` | Your `SP_ENTITY_ID` |
| `SAML_ASSERTION_CONSUMER_SERVICE_URL` | `True` | |
| `SAML_CERTIFICATE` | `False` | Path to your encryption/signing cert |
| `SAML_PRIVATE_KEY` | `False` | Path to your encryption/signing key |
| `SAML_AUTHN_REQUESTS_SIGNED` | `False` | Likely required by your production IdP |
| `SAML_METADATA_SIGNED` | `False` | Likely required by your production IdP |

#### Mappings
| `Name` | Required | Comment |
|------|----------|---------|
| `SAML_MAPPINGS_*` | `False` | HTTP HEADER |

The `*` is the attribute name returned by your SSO. The value is the HTTP header you want returned to `nginx`'s `auth_request`

#### PROXY
| `Name` | Required | Comment |
|------|----------|---------|
| `PROXY_HOST` | `False` | |
| `PROXY_PORT` | `False` | |
| `PROXY_USER` | `False` | |
| `PROXY_PASSWORD` | `False` | |

The only time it makes outbound http call is when it tries to load idp metadata from a remote URL

#### Cookie
| `Name` | Default | Comment |
|------|---------|---------|
| `COOKIE_KEY` | `saml-proxy` | |
| `COOKIE_PATH` | `/` | |
| `COOKIE_SECRET` | `SecureRandom.hex(64)` | **SET IT FOR PRODUCTION** |
| `COOKIE_EXPIRE_AFTER` | `nil` | Integer in seconds. Default to session only |

#### Via config file override
You can also put your override configs in `/app/config/`
