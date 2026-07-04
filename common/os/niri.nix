{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.sidonia;
in
lib.mkIf (cfg.desktop.enable && (cfg.desktop.compositor == "niri")) {
  programs.niri = {
    enable = true;
    package = lib.mkDefault (if cfg.graphics.legacyGpu then pkgs.niri-legacy else pkgs.niri);
    useNautilus = lib.mkDefault false;
    withUWSM = lib.mkDefault true;
    withXDG = lib.mkDefault true;
  };
}
