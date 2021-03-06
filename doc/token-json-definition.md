# token JSON schema

| Claim | Type | Description |
| ----- | ---- | ------------|
| client_id | string | Client identifier for the OAuth 2.0 client that requested this token.  |
| exp | string | Integer timestamp, measured in the number of seconds since January 1 1970 UTC, indicating when this token will expire, as defined in JWT RFC7519  |
| exp_sec | number | Cache expiration time in second. |
| consumer_id | string | Kong consumer id |
| token_type | string | "OAuth" or "UMA" |
| scope | space seperated list of scopes | OAuth scopes (not present for an UMA RPT) |
| iss | string | issuer of the toekn |
| permissions | Object | [UMA RPT permission claims](https://docs.kantarainitiative.org/uma/wg/rec-oauth-uma-federated-authz-2.0.html#uma-bearer-token-profile) |
| iat | string | timestamp when this token was originally issued |
| associated_rpt | string | token value of an RPT token that is being substituted for this OAuth token for the purpose of upstream management |
| associated_oauth_token | string | token value of an OAuth token that is associated with this RPT |
| pct | string | value of a PCT token |
| claim_tokens | Array of string | A list of tokens pushed with the original request |
