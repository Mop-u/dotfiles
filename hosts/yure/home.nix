{
  osConfig,
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  home.packages = [
    (pkgs.callPackage ../yuhata/packages/brow6elAppimage.nix { })
  ];
  wayland.windowManager.niri.settings = {
    layout.default-column-width.proportion = 1.;
  };
  services.shikane = {
    enable = true;
    settings.profile = [
      {
        name = "Undocked";
        output = [
          {
            enable = true;
            search = "n=LVDS-1";
            scale = 1.0;
          }
        ];
      }
    ];
  };
}
