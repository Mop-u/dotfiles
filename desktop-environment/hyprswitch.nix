{inputs, config, pkgs, lib, target, ... }: let
    configFile = "/home/${target.userName}/.config/hypr/hyprswitch.css";
    pkg = inputs.hyprswitch.packages.${pkgs.system}.default;
in {
    home-manager.users.${target.userName} = {
        home.packages = [pkg];

        wayland.windowManager.hyprland.settings = {
            env = [
                "WORKSPACES_PER_ROW,3"
            ];
            bind = [
                "SUPER, W, exec, hyprswitch gui"
            ];
            bindrn = [
                ",  escape, exec, hyprswitch close --kill"
            ];
        };

        home.file.hyprswitch = {
            enable = true;
            executable = false;
            target = configFile;
            text = ''
                .client-image {
                    margin: 15px;
                }

                .client-index {
                    margin: 6px;
                    padding: 5px;
                    font-size: inherit;
                    font-weight: bold;
                    border-radius: ${target.window.rounding}px;
                    border: none;
                    background-color: inherit;
                }

                .client {
                    border-radius: ${target.window.rounding}px;
                    border: none;
                    background-color: inherit;
                }

                .client:hover {
                    color: #${target.style.catppuccin.highlight.hex};
                    background-color: inherit;
                }

                .client_active {
                    border: none;
                }

                .workspace {
                    font-size: inherit;
                    font-weight: bold;
                    border-radius: ${target.window.rounding}px;
                    border: none;
                    background-color: inherit;
                }

                .workspace_special {
                    border: none;
                }

                .workspaces {
                    margin: 0px;
                }

                window {
                    font-size: 18px;
                    color: #${target.style.catppuccin.text.hex};
                    border-radius: ${target.window.rounding}px;
                    background-color: #${target.style.catppuccin.base.hex}${target.window.opacity.hex};
                    border: ${target.window.borderSize}px solid #${target.style.catppuccin.highlight.hex};
                    opacity: initial;
                }
            '';
        };
    };
    systemd.user.services.hyprswitch = {
        enable = true;
        wantedBy = ["hyprland-session.target"];
        serviceConfig = {
            ExecStart = "${pkg}/bin/hyprswitch init --show-title --custom-css '${configFile}'";
        };
        unitConfig = {
            Description = "Hyprland workspace switcher";
            PartOf = "hyprland-session.target";
        };
    };
}