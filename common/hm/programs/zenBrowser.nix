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
  programs.zen-browser = {
    # https://github.com/0xc000022070/zen-browser-flake/tree/main
    enable = lib.mkDefault true;
    setAsDefaultBrowser = lib.mkDefault true;
  };
}
