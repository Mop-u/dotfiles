{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.sidonia;
in
{
  options.programs.steam.extraEnv = lib.mkOption {
    description = "Extra environment variables for steam.";
    type = with lib.types; attrsOf (nullOr (coercedTo int (builtins.toString) str));
    default = { };
    apply = x: lib.filterAttrs (n: v: v != null) x;
  };
  config = lib.mkIf (cfg.desktop.enable) {
    programs = {
      steam = {
        enable = lib.mkDefault true;
        package = pkgs.steam.override {
          #extraProfile = "unset TZ";
          inherit (config.programs.steam) extraEnv;
        };
        protontricks.enable = lib.mkDefault true;
        localNetworkGameTransfers.openFirewall = lib.mkDefault true;
        extest.enable = lib.mkDefault true;
        extraCompatPackages = [
          pkgs.dwproton
          pkgs.proton-ge-bin
          pkgs.steam-play-none
        ];
      };
    };
    environment.systemPackages = [ pkgs.gamescope-wsi ]; # for gamescope hdr support

    home-manager.users.${cfg.userName} = {
      wayland.windowManager.niri.settings.window-rule = [
        {
          _children = [
            { match._props.app-id._raw = ''r#"^steam_app_\d+$"#''; }
            { match._props.app-id._raw = ''r#"^gamescope$"#''; }
          ];
          open-fullscreen = true;
        }
        {
          match._props = {
            app-id = "steam";
            title._raw = ''r#"^notificationtoasts_\d+_desktop$"#'';
          };
          open-focused = false;
          default-floating-position._props = {
            x = 10.0;
            y = 10.0;
            relative-to = "bottom-right";
          };
        }
      ];
    };
  };
}
