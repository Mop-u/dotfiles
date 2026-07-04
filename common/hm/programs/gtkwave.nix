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
  programs.gtkwave = {
    enable = lib.mkDefault false;
    settings = {
      splash_disable = "1";
      do_initial_zoom_fit = "1";
      highlight_wavewindow = "1";
      fill_waveform = "1";
      clipboard_mouseover = "1";
      disable_mouseover = "0";
      show_base_symbols = "0";
      fontname_signals = "Monospace 12";
      fontname_waves = "Monospace 12";
    };
  };
}
