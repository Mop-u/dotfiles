{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.sidonia.netbird;
in
{
  options.sidonia.netbird.oneTimeKey = lib.mkOption {
    description = "One-time key for enrolling this device into the netbird network";
    type = lib.types.nullOr lib.types.str;
    default = null;
  };

  config = lib.mkIf (cfg.oneTimeKey != null) {
    services.netbird = {
      useRoutingFeatures = lib.mkDefault "both";
      package = lib.mkDefault inputs.unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.netbird;
      clients = {
        sidonia = {
          port = lib.mkDefault 51820;
          login = {
            enable = lib.mkDefault true;
            setupKeyFile = lib.mkDefault "${pkgs.writeText "one-time-key" cfg.oneTimeKey}";
          };
          environment = {
            NB_MANAGEMENT_URL = "https://netbird.moppu.dev";
            NB_ADMIN_URL = "https://netbird.moppu.dev";
          };
          openFirewall = lib.mkDefault true;
          openInternalFirewall = lib.mkDefault true;
        };
      };
    };
  };
}
