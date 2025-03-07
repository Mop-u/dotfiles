{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
let
    cfg = config.sidonia;
    theme = cfg.style.catppuccin;
in
lib.mkIf (cfg.graphics.enable) {
    home-manager.users.${cfg.userName} = {
        catppuccin.waybar.enable = true;
        programs.waybar = {
            enable = true;
            systemd.enable = true;
            #package = inputs.waybar.packages.${pkgs.system}.waybar;
            settings.mainBar = {
                layer = "top";
                position = "top";
                spacing = 16;
                modules-left = [
                    "hyprland/workspaces"
                ];
                modules-center = [
                    "hyprland/window" # window title
                ];
                modules-right = [
                    "clock" # date & time
                    "hyprland/language" # keyboard region
                    "battery" # laptop battery state
                    "wireplumber" # audio
                    "tray" # system tray
                ];

                "hyprland/window" = {
                    format = "<b>{class}</b> {title}";
                    separate-outputs = true;
                    icon = true;
                };

                "hyprland/language".format = "   {}";

                clock = {
                    format = "   {:%H:%M}";
                    format-alt = "   {:%A, %B %d, %Y (%R)}";
                    tooltip-format = "<tt><small>{calendar}</small></tt>";
                    calendar = {
                        mode = "year";
                        mode-mon-col = 3;
                        weeks-pos = "right";
                        on-scroll = 1;
                        format = {
                            months = "<span color='#${theme.text.hex}'><b>{}</b></span>";
                            days = "<span color='#${theme.subtext0.hex}'><b>{}</b></span>";
                            weeks = "<span color='#${theme.overlay0.hex}'><b>W{}</b></span>";
                            weekdays = "<span color='#${theme.overlay0.hex}'><b>{}</b></span>";
                            today = "<span color='#${theme.highlight.hex}'><b><u>{}</u></b></span>";
                        };
                    };
                    actions = {
                        on-click-right = "mode"; # Switch calendar mode between year/month
                        on-click-forward = "tz_up"; # Switch to the next provided time zone
                        on-click-backward = "tz_down"; # Switch to the previous provided time zone
                        on-scroll-up = "shift_up"; # Switch to the previous calendar month/year
                        on-scroll-down = "shift_down"; # Switch to the previous calendar month/year
                        on-click-middle = "shift_reset"; # Switch to current calendar month/year
                    };
                };

                battery = {
                    format = "{icon}  {capacity}%";
                    format-icons = [
                        " "
                        " "
                        " "
                        " "
                        " "
                    ];
                    states = {
                        warning = 30;
                        critical = 15;
                    };
                };

                wireplumber = {
                    format = "{icon}  {volume}%";
                    format-muted = " ";
                    format-icons = [
                        " "
                        " "
                        " "
                    ];
                    on-click = "GSK_RENDERER=gl pwvucontrol";
                };

                tray = {
                    spacing = 8;
                    reverse-direction = false;
                };
            };
            style = ''
                @define-color accent @${theme.accent};
                #workspaces button {
                    color: @subtext0;
                    background-color: @base;
                }
                #workspaces button.urgent {
                    color: @text;
                    font-weight: bold;
                }
                #workspaces button.active {
                    background-color: @surface0;
                    color: @accent;
                    font-weight: bold;
                }
                #tray {
                    margin-right: 12px;
                }
            '';
        };
        home.file.waybarDropin = {
            enable = true;
            target = "/home/${cfg.userName}/.config/systemd/user/waybar.service.d/dropin.conf";
            text = ''
                [Service]
                RestartSec=5
            '';
        };
    };
}
