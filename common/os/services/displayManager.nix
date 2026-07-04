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
  config = lib.mkIf cfg.desktop.enable {
    services.displayManager = {
      autoLogin.enable = lib.mkDefault false;
      autoLogin.user = lib.mkDefault cfg.userName;
    };
    programs.noctalia-greeter = {
      enable = lib.mkDefault true;
      settings.cursor =
        with config.catppuccin;
        lib.mkIf enable {
          theme = lib.mkDefault "catppuccin-${flavor}-${accent}-cursors";
          package = lib.mkDefault sources.cursors."${flavor}${lib.toSentenceCase accent}";
        };
    };
  };
}
