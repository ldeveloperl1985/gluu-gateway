(function () {
  'use strict';

  angular.module('frontend.plugins')
    .controller('OpenIDPluginController', [
      '_', '$scope', '$log', '$state', 'PluginsService', 'MessageService',
      '$uibModal', 'DialogService', 'PluginModel', 'PluginHelperService', '_context_name', '_context_data', '_plugins', '$compile', 'InfoService', '$localStorage',
      function controller(_, $scope, $log, $state, PluginsService, MessageService,
                          $uibModal, DialogService, PluginModel, PluginHelperService, _context_name, _context_data, _plugins, $compile, InfoService, $localStorage) {
        $scope.globalInfo = $localStorage.credentials.user;
        $scope.context_data = (_context_data && _context_data.data) || null;
        $scope.context_name = _context_name || null;
        $scope.context_upstream = '';
        $scope.plugins = _plugins.data.data;
        $scope.oauthPlugin = null;
        $scope.addNewScope = addNewScope;
        $scope.fetchData = fetchData;
        $scope.customHeaders = [['CUSTOM_NUMBER', '123321123']];
        $scope.claimSupported = [['role', '==', '[Mm][Aa]']];

        $scope.acr_values_supported = [
          "passport_oxd_openidconnect",
          "auth_ldap_server",
          "u2f",
          "otp"
        ];
        $scope.scopes_supported = [
          "address",
          "phone",
          "mobile_phone",
          "clientinfo",
          "user_name",
          "openid",
          "uma_protection",
          "profile",
          "oxd",
          "permission",
          "email"
        ];
        $scope.claims_supported = [
          "street_address",
          "country",
          "zoneinfo",
          "birthdate",
          "role",
          "gender",
          "formatted",
          "user_name",
          "phone_mobile_number",
          "preferred_username",
          "inum",
          "locale",
          "updated_at",
          "nickname",
          "email",
          "website",
          "email_verified",
          "profile",
          "locality",
          "phone_number_verified",
          "given_name",
          "middle_name",
          "picture",
          "name",
          "phone_number",
          "postal_code",
          "region",
          "family_name"
        ];
        $scope.claims_supported_operator = ["==", "~="];

        if (_context_name == 'service') {
          $scope.context_upstream = $scope.context_data.protocol + "://" + $scope.context_data.host;
        } else if (_context_name == 'route') {
          $scope.context_upstream = $scope.context_data.protocols[0] + "://" + (($scope.context_data.hosts && $scope.context_data.hosts[0]) || ($scope.context_data.paths && $scope.context_data.paths[0]) || ($scope.context_data['methods'] && $scope.context_data['methods'][0]));
        } else if (_context_name == 'api') {
          $scope.context_upstream = $scope.context_data.upstream_url;
        }

        $scope.modelPlugin = {
          name: 'gluu-oauth-pep',
          config: {
            oxd_url: $scope.globalInfo.oxdWeb,
            op_url: $scope.globalInfo.opHost,
            oxd_id: $scope.globalInfo.oxdId,
            client_id: $scope.globalInfo.clientId,
            client_secret: $scope.globalInfo.clientSecret,
            authorization_redirect_path: '/callback',
            logout_path: '/logout',
            post_logout_redirect_uri: '/logout_redirect_uri',
            requested_scopes: ['openid', 'email', 'profile'],
            required_acrs: ['auth_ldap_server', 'u2f', 'otp'],
            max_id_token_age: 60,
            max_id_token_auth_age: 60
          }
        };

        if ($scope.context_name) {
          $scope.modelPlugin[$scope.context_name + "_id"] = $scope.context_data.id;
        } else {
          $scope.plugins = $scope.plugins.filter(function (item) {
            return (!(item.service_id || item.route_id || item.api_id))
          });
        }

        $scope.isPluginAdded = false;
        setTimeout(function () {
        $scope.plugins.forEach(function (o) {
          if (o.name == "gluu-openid") {
            $scope.modelPlugin = o;
            $scope.isPluginAdded = true;
          }
        })}, 100);
        /**
         * ----------------------------------------------------------------------
         * Functions
         * ----------------------------------------------------------------------
         */
        function fetchData() {
          InfoService
            .getInfo()
            .then(function (resp) {
              $scope.info = resp.data;
              if (!$scope.context_name) {
                $scope.context_upstream = "http://" + $scope.info.hostname + ":" + $scope.info.configuration.proxy_listeners[0].port;
              }
              $log.debug("DashboardController:fetchData:info", $scope.info);
            })
        }

        function addNewScope(scope) {
          if ($scope.scopes_supported.indexOf(scope) > -1) {
            MessageService.error('Duplicate values not allowed!');
            return
          }
          $scope.scopes_supported.push(angular.copy(scope));
          $scope.newScope = ''
        }
        //init
        $scope.fetchData()
      }
    ]);
}());