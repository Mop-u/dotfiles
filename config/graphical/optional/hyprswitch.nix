{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
let
    cfg = config.sidonia;
    configFile = "/home/${config.sidonia.userName}/.config/hypr/hyprswitch.css";
    hyprswitch = inputs.hyprswitch.packages.${pkgs.system}.default;
in
{
    options.sidonia.services.hyprswitch.enable = lib.mkEnableOption "Enable Hyprswitch";
    config = lib.mkIf (cfg.services.hyprswitch.enable) {
        sidonia.desktop.keybinds = [
            (rec {
                mod = ["super"];
                key = "tab";
                exec = lib.concatStringsSep " " [
                    "uwsm app --"
                    "hyprswitch gui"
                    "--mod-key ${lib.concatStrings mod}"
                    "--key ${key}"
                    "--close mod-key-release"
                ];
            })
        ];
        home-manager.users.${config.sidonia.userName} = {
            home.packages = [ hyprswitch ];

            home.file.hyprswitch = {
                enable = true;
                executable = false;
                target = configFile;
                text =
                    let
                        rounding = builtins.toString cfg.window.rounding;
                        borderSize = builtins.toString cfg.window.borderSize;
                        opacity = cfg.window.opacity.hex;
                        theme = cfg.style.catppuccin;
                        palette = builtins.mapAttrs (n: v: "#${v.hex}") theme.color;
                    in
                    with palette;
                    ''
                        .client-image {
                            margin: 15px;
                        }

                        .client-index {
                            margin: 6px;
                            padding: 5px;
                            font-size: inherit;
                            font-weight: bold;
                            border-radius: ${rounding}px;
                            border: none;
                            background-color: inherit;
                        }

                        .client {
                            border-radius: ${rounding}px;
                            border: none;
                            background-color: inherit;
                        }

                        .client:hover {
                            color: ${accent};
                            background-color: inherit;
                        }

                        .client_active {
                            border: none;
                        }

                        .workspace {
                            font-size: inherit;
                            font-weight: bold;
                            border-radius: ${rounding}px;
                            border: none;
                            background-color: inherit;
                        }

                        .workspace_special {
                            border: none;
                        }

                        .workspaces {
                            margin: 0px;
                        }

                        .index {
                            border-radius: ${rounding}px;
                            border: none;
                            background-color: inherit;
                        }

                        window {
                            font-size: 18px;
                            color: ${text};
                            border-radius: ${rounding}px;
                            background-color: ${base}${opacity};
                            border: ${borderSize}px solid ${accent};
                            opacity: initial;
                        }
                    '';
            };
        };
        systemd.user.services.hyprswitch = {
            enable = true;
            wantedBy = [ "wayland-session@Hyprland.target" ];
            serviceConfig = {
                ExecStart = "${hyprswitch}/bin/hyprswitch init --show-title --custom-css '${configFile}'";
            };
            unitConfig = {
                Description = "Hyprland workspace switcher";
                After = "wayland-session@Hyprland.target";
                Wants = "wayland-session@Hyprland.target";
                PartOf = "wayland-session@Hyprland.target";
            };
        };
    };
}
