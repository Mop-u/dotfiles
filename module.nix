{
    inputs,
    hostName
}:
{
    config,
    lib,
    pkgs,
    ...
}:
let
    cfg = config.sidonia;
in
{
    options = with lib; {
        sidonia = {
            lib = mkOption {
                readOnly = true;
                type = types.attrs;
                default = {
                    capitalize =
                        str:
                        let
                            chars = stringToCharacters str;
                        in
                        concatStrings ([ (toUpper (builtins.head chars)) ] ++ (builtins.tail chars));

                    isInstalled =
                        package:
                        builtins.elem package.pname (
                            builtins.catAttrs "pname" (
                                config.environment.systemPackages
                                ++ config.users.users.${cfg.userName}.packages
                                ++ config.home-manager.users.${cfg.userName}.home.packages
                            )
                        );

                    home = {
                        applications = "/home/${cfg.userName}/.nix-profile/share/applications";
                        autostart = "/home/${cfg.userName}/.config/autostart";
                    };
                };
            };
            ssh.pubKey = lib.mkOption {
                type = types.str;
            };
            hostName = mkOption {
                readOnly = true;
                type = types.str;
                default = hostName;
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
            tweaks = {
                withBehringerAudioInterface = mkEnableOption "Apply tweaks for some Behringer audio interfaces such as the UV1 and some UMC devices.";
            };
            geolocation.enable = mkEnableOption "Turn on geolocation related services such as automatic timezone changing and geoclue";
            isLaptop = mkEnableOption "Apply laptop-specific tweaks";
            graphics = {
                enable = mkEnableOption "Enable gui / desktop environment components";
                legacyGpu = mkEnableOption "Apply tweaks for OpenGL ES 2 device support";
            };
            style = {
                # use `apply` attribute in mkOption to convert input options & avoid hacking nixpkgs lib
                catppuccin = mkOption {
                    description = "Catppuccin configuration";
                    default = { };
                    type = types.submodule {
                        options = {
                            flavor = mkOption {
                                description = "Catppuccin theme flavor";
                                type = types.enum [
                                    "latte"
                                    "frappe"
                                    "macchiato"
                                    "mocha"
                                ];
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
                    apply =
                        x:
                        let
                            theme = (import ./lib/catppuccin.nix).catppuccin.${x.flavor};
                        in
                        {
                            inherit (x) flavor accent;
                            highlight = theme.${x.accent};
                            color = theme // {
                                accent = theme.${x.accent};
                            };
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
                default = { };
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
                        hex = toHexString (builtins.floor (x.opacity * 255));
                    };
                };
            };
            text = {
                smallTermFont = mkEnableOption "Shrink the terminal font slightly";
                comicCode = mkOption {
                    default = { };
                    type = types.submodule {
                        options.enable = mkEnableOption "Use Comic Code monospace font";
                    };
                    apply = x: {
                        inherit (x) enable;
                        package = inputs.nonfree-fonts.packages.${config.nixpkgs.system}.comic-code;
                        name = if x.enable then "Comic Code" else "ComicShannsMono Nerd Font";
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
                    type = types.enum [
                        "adaptive"
                        "flat"
                        "custom"
                    ];
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

    imports =
        let
            ls =
                with lib;
                dir: filter: mapAttrsToList (n: v: (path.append dir n)) (filterAttrs filter (builtins.readDir dir));
            lsFiles = dir: ls dir (n: v: v == "regular");
            #prefixList = prefix: list: (builtins.map (x: lib.path.append prefix x) list);
            headless = (lsFiles ./config/headless/core) ++ (lsFiles ./config/headless/optional);
            graphical = (lsFiles ./config/graphical/core) ++ (lsFiles ./config/graphical/optional);

        in
        headless
        ++ graphical
        ++ (with inputs; [
            catppuccin.nixosModules.catppuccin
            home-manager.nixosModules.home-manager
            lancache.nixosModules.dns
            lancache.nixosModules.cache
            aagl.nixosModules.default
            sops-nix.nixosModules.sops
            nix-minecraft.nixosModules.minecraft-servers
            quartus.nixosModules.quartus
        ]);

    config = lib.mkMerge [
        {
            home-manager.users.${cfg.userName}.imports = [ inputs.catppuccin.homeModules.catppuccin ];
        }
        (lib.mkIf cfg.tweaks.withBehringerAudioInterface {
            # Fix Behringer UV1 stutter https://github.com/arterro/notes/blob/main/behringer_uv1_linux_stutter.org
            boot = {
                extraModprobeConfig = ''
                    options snd_usb_audio implicit_fb=1
                '';
                kernelModules = [
                    "snd_usb_audio"
                ];
            };
        })
    ];
}
