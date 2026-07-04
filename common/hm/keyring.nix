{
  osConfig,
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = osConfig.sidonia;
in
lib.mkIf (cfg.desktop.enable) {
  services.gnome-keyring.enable = true;
  xdg.portal.config.common."org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
}
