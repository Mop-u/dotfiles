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
lib.mkIf cfg.desktop.enable {
  nixpkgs.config.permittedInsecurePackages = [ "openssl-1.1.1w" ];
  programs.sublime4 = {
    enable = lib.mkDefault true;
    settings = {
      ignored_packages = [ "Vintage" ];
      font_size = 10;
      translate_tabs_to_spaces = true;
      index_files = true;
      hardware_acceleration = if cfg.graphics.legacyGpu then "none" else "opengl";
      update_check = false;
      sublime_merge_path = lib.getExe pkgs.sublime-merge;
    };
    packageControl = {
      enable = true;
      packages = [
        "LSP"
        "Nix"
        "SystemVerilog"
        "hooks"
      ];
    };
    userFile = {
      "SystemVerilog.sublime-settings".text = builtins.toJSON {
        "sv.disable_autocomplete" = true;
        "sv.tooltip" = true;
      };
    };
  };
  programs.sublime-merge = {
    enable = lib.mkDefault true;
    settings = lib.mkMerge [
      {
        translate_tabs_to_spaces = true;
        side_bar_layout = "tabs";
        font_size = 10;
        hardware_acceleration = if cfg.graphics.legacyGpu then "none" else "opengl";
        update_check = false;
      }
      (lib.mkIf config.programs.sublime4.enable {
        editor_path = "${pkgs.sublime4}/bin/sublime_text";
      })
    ];
  };
}
