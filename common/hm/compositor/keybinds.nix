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
  wayland.desktopManager.sidonia.keybinds = [
    {
      name = "Close Active Window";
      mod = [
        "Super"
        "Shift"
      ];
      key = "C";
      perCompositor.niri = {
        _props.repeat = false;
        close-window = [ ];
      };
    }
    {
      name = "Close Active Window";
      mod = "Super";
      key = "MouseMiddle";
      perCompositor.niri = {
        _props.repeat = false;
        close-window = [ ];
      };
    }
    {
      name = "Exit Session";
      mod = [
        "Super"
        "Shift"
      ];
      key = "Q";
      perCompositor.niri.quit = [ ];
    }
    {
      name = "Toggle Window Floating";
      mod = "Super";
      key = "V";
      perCompositor.niri.toggle-window-floating = [ ];
    }
    {
      name = "Switch Focus Between Floating and Tiling";
      mod = [
        "Super"
        "Shift"
      ];
      key = "V";
      perCompositor.niri.switch-focus-between-floating-and-tiling = [ ];
    }
    {
      name = "Maximize Column";
      mod = [
        "Super"
        "Alt"
      ];
      key = "F";
      perCompositor.niri.maximize-column = [ ];
    }
    {
      name = "Toggle Fullscreen";
      mod = "Super";
      key = "F";
      perCompositor.niri.fullscreen-window = [ ];
    }
    {
      name = "Move Focus Left";
      mod = "Super";
      key = "H";
      perCompositor.niri.focus-column-left = [ ];
    }
    {
      name = "Move Focus Right";
      mod = "Super";
      key = "L";
      perCompositor.niri.focus-column-right = [ ];
    }
    {
      name = "Move Column Left";
      mod = [
        "Super"
        "Shift"
      ];
      key = "H";
      perCompositor.niri.move-column-left = [ ];
    }
    {
      name = "Move Column Left";
      mod = "Super";
      key = "MouseForward";
      perCompositor.niri.move-column-left = [ ];
    }
    {
      name = "Move Column Right";
      mod = [
        "Super"
        "Shift"
      ];
      key = "L";
      perCompositor.niri.move-column-right = [ ];
    }
    {
      name = "Move Column Right";
      mod = "Super";
      key = "MouseBack";
      perCompositor.niri.move-column-right = [ ];
    }
    {
      name = "Decrease Column Width";
      mod = [
        "Super"
        "Alt"
      ];
      key = "H";
      perCompositor.niri.switch-preset-column-width-back = [ ];
    }
    {
      name = "Decrease Column Width";
      mod = [
        "Super"
        "Alt"
      ];
      key = "WheelScrollDown";
      perCompositor.niri.switch-preset-column-width-back = [ ];
    }
    {
      name = "Increase Column Width";
      mod = [
        "Super"
        "Alt"
      ];
      key = "L";
      perCompositor.niri.switch-preset-column-width = [ ];
    }
    {
      name = "Increase Column Width";
      mod = [
        "Super"
        "Alt"
      ];
      key = "WheelScrollUp";
      perCompositor.niri.switch-preset-column-width = [ ];
    }
    {
      name = "Move Focus Down";
      mod = "Super";
      key = "J";
      perCompositor.niri.focus-window-or-workspace-down = [ ];
    }
    {
      name = "Move Focus Up";
      mod = "Super";
      key = "K";
      perCompositor.niri.focus-window-or-workspace-up = [ ];
    }
    {
      name = "Focus Monitor Right";
      mod = "Super";
      key = "Period";
      perCompositor.niri.focus-monitor-right = [ ];
    }
    {
      name = "Focus Monitor Left";
      mod = "Super";
      key = "Comma";
      perCompositor.niri.focus-monitor-left = [ ];
    }
    {
      name = "Center Column";
      mod = "Super";
      key = "B";
      perCompositor.niri.center-column = [ ];
    }
    {
      name = "Move Window Down";
      mod = [
        "Super"
        "Shift"
      ];
      key = "J";
      perCompositor.niri.move-window-down-or-to-workspace-down = [ ];
    }
    {
      name = "Move Window Up";
      mod = [
        "Super"
        "Shift"
      ];
      key = "K";
      perCompositor.niri.move-window-up-or-to-workspace-up = [ ];
    }
    {
      name = "Move Column to Right Monitor";
      mod = [
        "Super"
        "Shift"
      ];
      key = "Period";
      perCompositor.niri.move-column-to-monitor-right = [ ];
    }
    {
      name = "Move Column to Left Monitor";
      mod = [
        "Super"
        "Shift"
      ];
      key = "Comma";
      perCompositor.niri.move-column-to-monitor-left = [ ];
    }
    {
      name = "Screenshot Monitor";
      key = "Print";
      perCompositor.niri.screenshot-screen = [ ];
    }
    {
      name = "Screenshot Window";
      mod = "Super";
      key = "Print";
      perCompositor.niri.screenshot-window = [ ];
    }
    {
      name = "Screenshot Region";
      mod = [
        "Super"
        "Shift"
      ];
      key = "Print";
      perCompositor.niri.screenshot = [ ];
    }
    {
      name = "Scroll to Next Workspace";
      mod = "Super";
      key = "WheelScrollDown";
      perCompositor.niri = {
        _props.cooldown-ms = 150;
        focus-workspace-down = [ ];
      };
    }
    {
      name = "Scroll to Prev Workspace";
      mod = "Super";
      key = "WheelScrollUp";
      perCompositor.niri = {
        _props.cooldown-ms = 150;
        focus-workspace-up = [ ];
      };
    }
    {
      name = "Scroll Layout Right";
      mod = [
        "Super"
        "Shift"
      ];
      key = "WheelScrollDown";
      perCompositor.niri = {
        _props.cooldown-ms = 150;
        focus-column-right = [ ];
      };
    }
    {
      name = "Scroll Layout Left";
      mod = [
        "Super"
        "Shift"
      ];
      key = "WheelScrollUp";
      perCompositor.niri = {
        _props.cooldown-ms = 150;
        focus-column-left = [ ];
      };
    }
    {
      name = "Toggle Overview";
      mod = "Super";
      key = "Space";
      perCompositor.niri = {
        _props.repeat = false;
        toggle-overview = [ ];
      };
    }
  ]
  ++ (builtins.concatLists (
    let
      count = 10;
    in
    builtins.genList (
      x:
      let
        index = x + 1;
        key = toString (lib.mod index count);
        name = toString index;
      in
      [
        {
          name = "Focus Workspace ${name}";
          mod = "Super";
          inherit key;
          perCompositor.niri.focus-workspace = index;
        }
        {
          name = "Move Window to Workspace ${name}";
          mod = [
            "Super"
            "Shift"
          ];
          inherit key;
          perCompositor.niri.move-window-to-workspace = index;
        }
        {
          name = "Move Window to Workspace ${name} (No Focus)";
          mod = [
            "Super"
            "Ctrl"
          ];
          inherit key;
          perCompositor.niri.move-window-to-workspace = {
            _props.focus = false;
            _args = [ index ];
          };
        }
      ]
    ) count
  ));
}
