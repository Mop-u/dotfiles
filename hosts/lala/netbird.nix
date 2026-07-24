{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
let
  unstable = inputs.unstable.legacyPackages.${config.nixpkgs.hostPlatform.system};
  domain = "netbird.moppu.dev";
  url = "https://${domain}";
  enable = false;
  enableNginx = false;
in
{
  services.netbird.server = {
    inherit enable enableNginx domain;
    coturn = {
      inherit enable domain;
      password = "netbird";
    };
    dashboard = {
      inherit enable enableNginx domain;
      package = unstable.netbird-dashboard;
      settings = {
        # https://github.com/netbirdio/netbird/blob/b65ec8b68a6a1ab8aee162a7b9e5147c0375af68/infrastructure_files/getting-started.sh#L931
        NETBIRD_MGMT_API_ENDPOINT = url;
        NETBIRD_MGMT_GRPC_API_ENDPOINT = url;
        AUTH_AUTHORITY = "${url}/oauth2";
        AUTH_SUPPORTED_SCOPES = "openid profile email groups";
        # AUTH_REDIRECT_URL = "/nb-auth";
        # AUTH_SILENT_REDIRECT_URL = "/nb-silent-auth";
        # LETSENCRYPT_DOMAIN = "none";
      };
    };
    management = {
      inherit enable enableNginx domain;
      package = unstable.netbird-management;
      oidcConfigEndpoint = "${url}/oauth2/.well-known/openid-configuration";
      turnDomain = domain;
      settings = {
      };
    };
    signal = {
      inherit enable enableNginx domain;
      package = unstable.netbird-signal;
    };
  };
}
