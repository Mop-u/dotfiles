{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  services.netbird = {
    useRoutingFeatures = "both";
    package = inputs.unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.netbird;
    clients = {
      sidonia = {
        port = 51820;
        login = {
          enable = true;
          setupKeyFile = "${pkgs.writeText "one-time-key" "55E39BBC-B480-4272-9577-B7046E432A3F"}";
        };
        environment = {
          NB_MANAGEMENT_URL = "https://netbird.moppu.dev";
          NB_ADMIN_URL = "https://netbird.moppu.dev";
        };
        openFirewall = true;
        openInternalFirewall = true;
      };
    };
  };
}
