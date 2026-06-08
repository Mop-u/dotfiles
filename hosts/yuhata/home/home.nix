{
  osConfig,
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  home.packages = with pkgs; [
    nix-index
    bs-manager
    via
    qmk
    (limo.override { withUnrar = true; })
    veadotube
    # (pkgs.callPackage ../packages/brow6el.nix { })
    wl-clipboard
  ];
  programs = {
    mangohud.enable = true;
  };
}
