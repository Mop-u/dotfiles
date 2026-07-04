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
  programs.bemenu = {
    enable = true;
    settings = with config.wayland.desktopManager.sidonia.window.decoration; {
      no-exec = true;
      prompt = "open";
      ignorecase = true;
      list = "16 down";
      wrap = true;
      center = true;
      no-overlap = true;
      single-instance = true;
      width-factor = 0.33;
      border = borderWidth;
      border-radius = rounding;
    };
  };
  wayland.desktopManager.sidonia.keybinds = [
    {
      name = "Bemenu";
      mod = [
        "Super"
        "Shift"
      ];
      key = "P";
      exec = "$(bemenu-run)";
    }
  ]
  ++ (lib.optional osConfig.hardware.nvidia.prime.offload.enableOffloadCmd {
    name = "Bemenu (Discrete GPU)";
    mod = [
      "Super"
      "Ctrl"
    ];
    key = "P";
    exec = "LIBVA_DRIVER_NAME=nvidia VDPAU_NAME=nvidia nvidia-offload $(bemenu-run)";
  });
}
