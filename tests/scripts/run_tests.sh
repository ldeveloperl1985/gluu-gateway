#!/bin/bash

DISTRIBUTION=$1

# Install JQ for JSON parse in test case
wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
chmod +x ./jq
cp jq /usr/bin

# Init
HOST=$2
OP_HOST=$3
OXD_HOST='localhost'
KONG_PROXY_HOST=$2
KONG_ADMIN_HOST='localhost'
OXD_PORT=8443

# Create service in kong
SERVICE_RESPONSE=`curl -k -X POST http://$KONG_ADMIN_HOST:8001/services/  -H 'Content-Type: application/json'  -d '{"name":"jsonplaceholder","url":"https://jsonplaceholder.typicode.com"}'`

SERVICE_ID=`echo $SERVICE_RESPONSE | jq -r ".id"`
echo "SERVICE_ID " .. $SERVICE_ID

ROUTE_RESPONSE=`curl -k -X POST http://$KONG_ADMIN_HOST:8001/routes/ -H 'Content-Type: application/json' -d '{"hosts": ["jsonplaceholder.typicode.com"],"service": {"id": "'$SERVICE_ID'"}}'`

ROUTE_ID=`echo $ROUTE_RESPONSE | jq -r ".id"`
echo "ROUTE_ID " .. $ROUTE_ID

# Create OP Client for OAuth plugin

OP_CLIENT_RESPONSE=`curl -k -X POST https://$OXD_HOST:$OXD_PORT/register-site  -H "Content-Type: application/json" -d  '{"client_name":"test_oauth_pep","access_token_as_jwt":true,"rpt_as_jwt":true,"access_token_signing_alg":"RS256", "op_host":"https://'$OP_HOST'", "authorization_redirect_uri": "https://client.example.com/cb", "grant_types":["client_credentials"]}'`

OXD_ID=`echo $OP_CLIENT_RESPONSE | jq -r ".oxd_id"`
CLIENT_ID=`echo $OP_CLIENT_RESPONSE | jq -r ".client_id"`
CLIENT_SECRET=`echo $OP_CLIENT_RESPONSE | jq -r ".client_secret"`
echo "OXD_ID " .. $OXD_ID
echo "CLIENT_ID " .. $CLIENT_ID
echo "CLIENT_SECRET " .. $CLIENT_SECRET

# Config plugins
## OAUTH-AUTH
OAUTH_PLUGIN_RESPONSE=`curl -k -X POST http://$KONG_ADMIN_HOST:8001/plugins/  -H 'Content-Type: application/json'  -d '{"name":"gluu-oauth-auth","config":{"oxd_url":"https://'$OXD_HOST':'$OXD_PORT'","op_url":"https://'$OP_HOST'","oxd_id":"'$OXD_ID'","client_id":"'$CLIENT_ID'","client_secret":"'$CLIENT_SECRET'","pass_credentials":"pass"},"service_id":"'$SERVICE_ID'"}'`

OAUTH_PLUGIN_ID=`echo $OAUTH_PLUGIN_RESPONSE | jq -r ".id"`
echo $OAUTH_PLUGIN_RESPONSE
echo "OAUTH_AUTH_PLUGIN_ID " .. $OAUTH_PLUGIN_ID

## OAUTH-PEP
OAUTH_PLUGIN_RESPONSE=`curl -k -X POST http://$KONG_ADMIN_HOST:8001/plugins/  -H 'Content-Type: application/json'  -d '{"name":"gluu-oauth-pep","config":{"method_path_tree":{"POST":{"posts":{"??":{"#":{"path":"/posts/??","scope_expression":{"rule":{"and":[{"var":0},{"var":1}]},"data":["oxd","openid"]}}}},"comments":{"??":{"#":{"path":"/comments/??","scope_expression":{"rule":{"and":[{"var":0}]},"data":["oxd"]}}}}},"DELETE":{"posts":{"??":{"#":{"path":"/posts/??","scope_expression":{"rule":{"and":[{"var":0},{"var":1}]},"data":["oxd","openid"]}}}},"comments":{"??":{"#":{"path":"/comments/??","scope_expression":{"rule":{"and":[{"var":0}]},"data":["oxd"]}}}}},"PUT":{"posts":{"??":{"#":{"path":"/posts/??","scope_expression":{"rule":{"and":[{"var":0},{"var":1}]},"data":["oxd","openid"]}}}},"comments":{"??":{"#":{"path":"/comments/??","scope_expression":{"rule":{"and":[{"var":0}]},"data":["oxd"]}}}}},"GET":{"posts":{"??":{"#":{"path":"/posts/??","scope_expression":{"rule":{"and":[{"var":0},{"var":1}]},"data":["oxd","openid"]}}}},"comments":{"??":{"#":{"path":"/comments/??","scope_expression":{"rule":{"and":[{"var":0}]},"data":["oxd"]}}}}}},"client_id":"'$CLIENT_ID'","oauth_scope_expression":[{"path":"/posts/??","conditions":[{"httpMethods":["GET","DELETE","POST","PUT"],"scope_expression":{"rule":{"and":[{"var":0},{"var":1}]},"data":["oxd","openid"]}}]},{"path":"/comments/??","conditions":[{"httpMethods":["GET","DELETE","POST","PUT"],"scope_expression":{"rule":{"and":[{"var":0}]},"data":["oxd"]}}]}],"op_url":"https://'$OP_HOST'","deny_by_default":true,"oxd_url":"https://'$OXD_HOST':'$OXD_PORT'","client_secret":"'$CLIENT_SECRET'","oxd_id":"'$OXD_ID'"},"service_id":"'$SERVICE_ID'"}'`

OAUTH_PLUGIN_ID=`echo $OAUTH_PLUGIN_RESPONSE | jq -r ".id"`
echo "OAUTH_PEP_PLUGIN_ID " .. $OAUTH_PLUGIN_ID

# Create OP Client for Consumer

OP_CLIENT_RESPONSE=`curl -k -X POST https://$OXD_HOST:$OXD_PORT/register-site  -H "Content-Type: application/json" -d  '{"client_name":"test_oauth_pep","access_token_as_jwt":true,"rpt_as_jwt":true,"access_token_signing_alg":"RS256", "op_host":"https://'$OP_HOST'", "authorization_redirect_uri": "https://client.example.com/cb", "grant_types":["client_credentials"], "scope": ["openid", "oxd", "uma_protection"]}'`

CONSUMER_OXD_ID=`echo $OP_CLIENT_RESPONSE | jq -r ".oxd_id"`
CONSUMER_CLIENT_ID=`echo $OP_CLIENT_RESPONSE | jq -r ".client_id"`
CONSUMER_CLIENT_SECRET=`echo $OP_CLIENT_RESPONSE | jq -r ".client_secret"`
echo "OXD_ID " .. $CONSUMER_OXD_ID
echo "CLIENT_ID " .. $CONSUMER_CLIENT_ID
echo "CLIENT_SECRET " .. $CONSUMER_CLIENT_SECRET


# Create kong consumer
CONSUMER_RESPONSE=`curl -k -X POST http://$KONG_ADMIN_HOST:8001/consumers/  -H 'Content-Type: application/json'  -d '{"username":"cons_jsonplaceholder","custom_id":"'$CONSUMER_CLIENT_ID'"}'`

CONSUMER_ID=`echo $CONSUMER_RESPONSE | jq -r ".id"`
echo "CONSUMER_ID " .. $CONSUMER_ID


# OAUTH
RESPONSE=`curl -k -X POST https://$OXD_HOST:$OXD_PORT/get-client-token -H "Content-Type: application/json" -d '{"client_id":"'$CONSUMER_CLIENT_ID'","client_secret":"'$CONSUMER_CLIENT_SECRET'","op_host":"'$OP_HOST'", "scope":["openid", "oxd", "uma_protection"]}'`

TOKEN=`echo $RESPONSE | jq -r ".access_token"`
echo "Access Token " .. $TOKEN


curl -X GET http://$KONG_PROXY_HOST:8000/posts/1 -H "Authorization: Bearer $TOKEN"  -H 'Host: jsonplaceholder.typicode.com'
curl -X GET http://$KONG_PROXY_HOST:8000/posts/1 -H "Authorization: Bearer $TOKEN"  -H 'Host: jsonplaceholder.typicode.com'
curl -X GET http://$KONG_PROXY_HOST:8000/posts/1 -H "Authorization: Bearer $TOKEN"  -H 'Host: jsonplaceholder.typicode.com'
CHECK_STATUS=`curl -H "Authorization: Bearer $TOKEN"  -H 'Host: jsonplaceholder.typicode.com' --write-out "%{http_code}\n" --silent --output /dev/null http://$KONG_PROXY_HOST:8000/posts/1`

if [ "$CHECK_STATUS" != "200" ]; then
    echo "OAuth PEP security fail"
    exit 1
fi

# =========================================================================
# Create another service in kong
echo "========================================================================="
echo "Create another service in kong"

SERVICE_RESPONSE=`curl -k -X POST http://$KONG_ADMIN_HOST:8001/services/  -H 'Content-Type: application/json'  -d '{"name":"jsonplaceholder2","url":"https://jsonplaceholder.typicode.com"}'`

SERVICE_ID=`echo $SERVICE_RESPONSE | jq -r ".id"`
echo "SERVICE_ID " .. $SERVICE_ID

ROUTE_RESPONSE=`curl -k -X POST http://$KONG_ADMIN_HOST:8001/routes/ -H 'Content-Type: application/json' -d '{"hosts": ["jsonplaceholder2.typicode.com"],"service": {"id": "'$SERVICE_ID'"}}'`

ROUTE_ID=`echo $ROUTE_RESPONSE | jq -r ".id"`
echo "ROUTE_ID " .. $ROUTE_ID

# Create OP Client for UMA_PEP

OP_CLIENT_RESPONSE=`curl -k -X POST https://$OXD_HOST:$OXD_PORT/register-site  -H "Content-Type: application/json" -d  '{"client_name":"test_uma_pep", "op_host":"https://'$OP_HOST'", "authorization_redirect_uri": "https://client.example.com/cb", "scope": ["openid", "oxd", "uma_protection"], "grant_types":["client_credentials"]}'`

OXD_ID=`echo $OP_CLIENT_RESPONSE | jq -r ".oxd_id"`
CLIENT_ID=`echo $OP_CLIENT_RESPONSE | jq -r ".client_id"`
CLIENT_SECRET=`echo $OP_CLIENT_RESPONSE | jq -r ".client_secret"`
echo "OXD_ID " .. $OXD_ID
echo "CLIENT_ID " .. $CLIENT_ID
echo "CLIENT_SECRET " .. $CLIENT_SECRET

# Register resources using OXD
# GET PROTECTION TOKEN
RESPONSE=`curl -k -X POST https://$OXD_HOST:$OXD_PORT/get-client-token -H "Content-Type: application/json" -d '{"client_id":"'$CLIENT_ID'","client_secret":"'$CLIENT_SECRET'","op_host":"'$OP_HOST'", "scope":["openid", "oxd", "uma_protection"]}'`

TOKEN=`echo $RESPONSE | jq -r ".access_token"`
echo "PROTECTION TOKEN " .. $TOKEN

RS_PROTECT_CLIENT_RESPONSE=`curl -k -X POST https://$OXD_HOST:$OXD_PORT/uma-rs-protect -H "Authorization: Bearer $TOKEN"  -H "Content-Type: application/json" -d  '{"oxd_id":"'$OXD_ID'","resources":[{"path":"/posts/??","conditions":[{"httpMethods":["GET","DELETE","POST","PUT"],"scope_expression":{"rule":{"and":[{"var":0},{"var":1}]},"data":["admin","employee"]}}]},{"path":"/comments/??","conditions":[{"httpMethods":["GET","DELETE","POST","PUT"],"scope_expression":{"rule":{"and":[{"var":0}]},"data":["admin"]}}]}]}'`

echo "RS_PROTECT_CLIENT_RESPONSE " .. $RS_PROTECT_CLIENT_RESPONSE

# Create anonymous kong consumer
anonymous_CONSUMER_RESPONSE=`curl -k -X POST http://$KONG_ADMIN_HOST:8001/consumers/  -H 'Content-Type: application/json'  -d '{"username":"anonymous","custom_id":"anonymous"}'`

anonymous_CONSUMER_ID=`echo $anonymous_CONSUMER_RESPONSE | jq -r ".id"`
echo "anonymous CONSUMER_ID " .. $anonymous_CONSUMER_ID

# Config plugin
## UMA-AUTH
UMA_PLUGIN_RESPONSE=`curl -k -X POST http://$KONG_ADMIN_HOST:8001/plugins/  -H 'Content-Type: application/json'  -d '{"name":"gluu-uma-auth","config":{"anonymous": "'$anonymous_CONSUMER_ID'", "oxd_url":"https://'$OXD_HOST':'$OXD_PORT'","op_url":"https://'$OP_HOST'","oxd_id":"'$OXD_ID'","client_id":"'$CLIENT_ID'","client_secret":"'$CLIENT_SECRET'","pass_credentials":"pass"},"service_id":"'$SERVICE_ID'"}'`

UMA_PLUGIN_ID=`echo $UMA_PLUGIN_RESPONSE | jq -r ".id"`
echo "UMA_AUTH_PLUGIN_ID " .. $UMA_PLUGIN_ID

## UMA-PEP
UMA_PLUGIN_RESPONSE=`curl -k -X POST http://$KONG_ADMIN_HOST:8001/plugins/  -H 'Content-Type: application/json'  -d '{"name":"gluu-uma-pep","config":{"oxd_url":"https://'$OXD_HOST':'$OXD_PORT'","op_url":"https://'$OP_HOST'","oxd_id":"'$OXD_ID'","client_id":"'$CLIENT_ID'","client_secret":"'$CLIENT_SECRET'","uma_scope_expression":[{"path":"/posts/??","conditions":[{"httpMethods":["GET","POST","PUT","PATCH","DELETE"]}]},{"path":"/comments/??","conditions":[{"httpMethods":["GET","DELETE","POST","PUT","PATCH"]}]}],"method_path_tree":{"DELETE":{"posts":{"??":{"#":{"path":"/posts/??"}}},"comments":{"??":{"#":{"path":"/comments/??"}}}},"PUT":{"posts":{"??":{"#":{"path":"/posts/??"}}},"comments":{"??":{"#":{"path":"/comments/??"}}}},"POST":{"posts":{"??":{"#":{"path":"/posts/??"}}},"comments":{"??":{"#":{"path":"/comments/??"}}}},"PATCH":{"posts":{"??":{"#":{"path":"/posts/??"}}},"comments":{"??":{"#":{"path":"/comments/??"}}}},"GET":{"posts":{"??":{"#":{"path":"/posts/??"}}},"comments":{"??":{"#":{"path":"/comments/??"}}}}},"deny_by_default":true},"service_id":"'$SERVICE_ID'"}'`

UMA_PLUGIN_ID=`echo $UMA_PLUGIN_RESPONSE | jq -r ".id"`
echo "UMA_PEP_PLUGIN_ID " .. $UMA_PLUGIN_ID

# UMA Auth
TICKET=`curl -i -sS -X GET http://$KONG_PROXY_HOST:8000/posts/1 -H 'Host: jsonplaceholder2.typicode.com' | sed -n 's/.*ticket="//p'`
TICKET="${TICKET%??}"
echo "TICKET " .. $TICKET

RESPONSE=`curl -k -X POST https://$OXD_HOST:$OXD_PORT/get-client-token -H "Content-Type: application/json" -d '{"client_id":"'$CONSUMER_CLIENT_ID'","client_secret":"'$CONSUMER_CLIENT_SECRET'","op_host":"'$OP_HOST'", "scope":["openid", "oxd", "uma_protection"]}'`

TOKEN=`echo $RESPONSE | jq -r ".access_token"`
echo "PROTECTION Token " .. $TOKEN

RESPONSE=`curl -k -X POST https://$OXD_HOST:$OXD_PORT/uma-rp-get-rpt -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d '{"oxd_id":"'$CONSUMER_OXD_ID'","ticket":"'$TICKET'"}'`

echo $RESPONSE
TOKEN=`echo $RESPONSE | jq -r ".access_token"`
echo "RPT Token " .. $TOKEN

curl -X GET http://$KONG_PROXY_HOST:8000/posts/1 -H "Authorization: Bearer $TOKEN"  -H 'Host: jsonplaceholder2.typicode.com'
curl -X GET http://$KONG_PROXY_HOST:8000/posts/1 -H "Authorization: Bearer $TOKEN"  -H 'Host: jsonplaceholder2.typicode.com'
curl -X GET http://$KONG_PROXY_HOST:8000/posts/1 -H "Authorization: Bearer $TOKEN"  -H 'Host: jsonplaceholder2.typicode.com'

CHECK_STATUS=`curl -H "Authorization: Bearer $TOKEN"  -H 'Host: jsonplaceholder2.typicode.com' --write-out "%{http_code}\n" --silent --output /dev/null http://$KONG_PROXY_HOST:8000/posts/1`

if [ "$CHECK_STATUS" != "200" ]; then
    echo "UMA PEP security fail"
    exit 1
fi

ss -ntlp
