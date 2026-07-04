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

  home.packages = [ pkgs.nwg-look ];

  dconf.settings = with lib.gvariant; {
    "org/gnome/desktop/interface" = {
      color-scheme = if config.catppuccin.flavor == "latte" then "prefer-light" else "prefer-dark";
    };
  };
  gtk = {
    enable = true;
    gtk4.theme = config.gtk.theme;
    theme =
      let
        shade = if config.catppuccin.flavor == "latte" then "light" else "dark";
        doTweak = builtins.elem config.catppuccin.flavor [
          "frappe"
          "macchiato"
        ];
      in
      {
        package = pkgs.magnetic-catppuccin-gtk.override {
          inherit shade;
          tweaks = lib.optional doTweak config.catppuccin.flavor;
          accent = [ config.catppuccin.accent ];
        };
        name = lib.strings.concatStringsSep "-" (
          [
            "Catppuccin-GTK"
            (cfg.lib.capitalize config.catppuccin.accent)
            (cfg.lib.capitalize shade)
          ]
          ++ (lib.optional doTweak (cfg.lib.capitalize config.catppuccin.flavor))
        );
      };
  };
}
