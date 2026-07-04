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
lib.mkIf (cfg.desktop.enable && (cfg.desktop.shell == "noctalia")) {
  wayland.desktopManager.sidonia.keybinds =
    let
      noctalia = args: "noctalia msg ${args}";
    in
    [
      {
        name = "Toggle Launcher";
        mod = "super";
        key = "p";
        exec = noctalia "panel-toggle launcher";
      }
      {
        name = "Toggle Session Menu";
        mod = "super";
        key = "q";
        exec = noctalia "panel-toggle session";
      }
      {
        name = "Lock Screen";
        mod = "super";
        key = "x";
        exec = noctalia "screen-lock";
      }
      {
        name = "Volume Up";
        key = "XF86AudioRaiseVolume";
        exec = noctalia "volume-up";
      }
      {
        name = "Volume Down";
        key = "XF86AudioLowerVolume";
        exec = noctalia "volume-down";
      }
      {
        name = "Mute Output";
        key = "XF86AudioMute";
        exec = noctalia "volume-mute";
      }
      {
        name = "Mute Input";
        key = "XF86AudioMicMute";
        exec = noctalia "mic-mute";
      }
      {
        name = "Media Play";
        key = "XF86AudioPlay";
        exec = noctalia "media toggle";
      }
      {
        name = "Media Pause";
        key = "XF86AudioPause";
        exec = noctalia "media toggle";
      }
      {
        name = "Media Next";
        key = "XF86AudioNext";
        exec = noctalia "media next";
      }
      {
        name = "Media Prev";
        key = "XF86AudioPrev";
        exec = noctalia "media previous";
      }
      {
        name = "Brightness Up";
        key = "XF86MonBrightnessUp";
        exec = noctalia "brightness-up";
      }
      {
        name = "Brightness Down";
        key = "XF86MonBrightnessDown";
        exec = noctalia "brightness-down";
      }
    ];
}
