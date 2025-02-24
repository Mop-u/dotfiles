{inputs}: {config, lib, pkgs, ... }: let
    cfg = config.sidonia;
in {
    options = with lib; { 
        sidonia = {
            hostName = mkOption {
                type = types.str;
                default = "nixos";
            };
            userName = mkOption {
                description = "Username of main user";
                type = types.str;
            };
            stateVer = mkOption {
                description = "NixOS state version";
                type = types.str;
            };
            system = mkOption {
                description = "System architecture";
                type = types.enum [
                    "x86_64-linux"
                    "x86_64-darwin"
                    "i686-linux"
                    "aarch64-linux"
                    "aarch64-darwin"
                    "armv6l-linux"
                    "armv7l-linux"
                ];
                default = "x86_64-linux";
            };
            monitors = mkOption {
                description = "List of monitor configurations";
                type = with types; listOf (submodule { 
                    options = {
                        name = mkOption {
                            description = "Name of monitor ( see https://wiki.hyprland.org/Configuring/Monitors/ )";
                            type = str;
                        };
                        resolution = mkOption {
                            description = "Resolution in the format WIDTHxHEIGHT. Default is highest available resolution.";
                            type = str;
                            default = "highres";
                        };
                        position = mkOption {
                            description = "Monitor position in scaled pixels WIDTHxHEIGHT";
                            type = str;
                            default = "auto";
                        };
                        refresh = mkOption {
                            description = "Monitor refresh rate";
                            type = float;
                            default = 0.0;
                        };
                        scale = mkOption {
                            description = "Monitor scale factor";
                            type = float;
                            default = 1.0;
                        };
                        extraArgs = mkOption {
                            description = "Monitor properties ( see https://wiki.hyprland.org/Configuring/Monitors/ )";
                            type = str;
                            default = "";
                        };
                    };
                });
                default = [];
            };
            isLaptop = mkEnableOption "Apply laptop-specific tweaks";
            graphics = {
                legacyGpu = mkEnableOption "Apply tweaks for OpenGL ES 2 device support";
                headless = mkEnableOption "Disable graphical components e.g. for server installs";
            };
            style = {
                # use `apply` attribute in mkOption to convert input options & avoid hacking nixpkgs lib
                catppuccin = mkOption {
                    description = "Catppuccin configuration";
                    default = {};
                    type = types.submodule {
                        options = {
                            flavor = mkOption {
                                description = "Catppuccin theme flavor";
                                type = types.enum [ "latte" "frappe" "macchiato" "mocha" ];
                                default = "frappe";
                            };
                            accent = mkOption {
                                description = "Catppuccin theme accent";
                                type = types.enum [
                                    "rosewater"
                                    "flamingo"
                                    "pink"
                                    "mauve"
                                    "red"
                                    "maroon"
                                    "peach"
                                    "yellow"
                                    "green"
                                    "teal"
                                    "sky"
                                    "sapphire"
                                    "blue"
                                    "lavender"
                                ];
                                default = "mauve";
                            };
                        };
                    };
                    apply = x: let
                        theme = (import ./catppuccin.nix).catppuccin.${x.flavor};
                    in theme // {
                        inherit (x) flavor accent;
                        highlight = theme.${x.accent};
                    };
                };
                cursorSize = mkOption {
                    description = "Cursor size";
                    type = types.int;
                    default = 30;
                };
            };
            window = mkOption {
                description = "Window configuration";
                default = {};
                type = types.submodule {
                    options = {
                        float.w = mkOption {
                            description = "Default floating window width";
                            type = types.int;
                            default = 896;
                        };
                        float.h = mkOption {
                            description = "Default floating window height";
                            type = types.int;
                            default = 504;
                        };
                        borderSize = mkOption {
                            description = "Border width";
                            type = types.int;
                            default = 2;
                        };
                        rounding = mkOption {
                            description = "Window rounding";
                            type = types.int;
                            default = 10;
                        };
                        opacity = mkOption {
                            description = "Decimal opacity value for floating window transparency.";
                            type = types.float;
                            default = 0.8;
                        };
                    };
                };
                apply = x: {
                    float = {
                        inherit (x.float) w h;
                        wh = (builtins.toString x.float.w) + " " + (builtins.toString x.float.h);
                        onCursor = "move onscreen cursor -50% -50%";
                    };
                    inherit (x) borderSize rounding;
                    opacity = {
                        dec = x.opacity;
                        hex = toHexString (builtins.floor (x.opacity*255));
                    };
                };
            };
            text = {
                smallTermFont = mkEnableOption "Shrink the terminal font slightly";
                comicCode = mkOption {
                    default = {};
                    type = types.submodule {
                        options.enable = mkEnableOption "Use Comic Code monospace font";
                    };
                    apply = x: {
                        inherit (x) enable;
                        package = inputs.nonfree-fonts.packages.${cfg.system}.comic-code;
                        name = "Comic Code";
                    };
                };
            };
            input = {
                sensitivity = mkOption {
                    description = "Mouse sensitivity range from -1.0 to 1.0";
                    type = types.float;
                    default = 0.0;
                };
                accelProfile = mkOption {
                    description = "Hyprland mouse acceleration profile";
                    type = types.enum ["adaptive" "flat" "custom"];
                    default = "flat";
                };
                keyLayout = mkOption {
                    description = "Keyboard layout";
                    type = types.str;
                    default = "us";
                };
            };
        };
    };

}