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
  xdg = {
    autostart.enable = true;
    portal = {
      enable = lib.mkDefault osConfig.xdg.portal.enable;
      xdgOpenUsePortal = lib.mkDefault osConfig.xdg.portal.xdgOpenUsePortal;
      extraPortals = osConfig.xdg.portal.extraPortals;
      config = {
        common = {
          default = [
            "gtk"
            "gnome"
          ];
          "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
          "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
        };
      };
    };
    mimeApps =
      let
        imageViewer = "qimgv.desktop";
      in
      {
        enable = true;
        defaultApplications = {
          "image/jpg" = [ imageViewer ];
          "image/jpeg" = [ imageViewer ];
          "image/png" = [ imageViewer ];
          "image/bmp" = [ imageViewer ];
          "image/gif" = [ imageViewer ];
          "image/webp" = [ imageViewer ];
          "image/x-sony-arw" = [ imageViewer ];
        };
        associations.added = {
          "image/jpg" = imageViewer;
        };
      };
  };
}
