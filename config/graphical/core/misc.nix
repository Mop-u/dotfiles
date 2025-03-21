{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
let
    cfg = config.sidonia;
in
lib.mkIf (cfg.graphics.enable) {

    security = {
        pam.services.hyprlock = { };
    };

    # enable virtual camera for OBS
    boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    boot.extraModprobeConfig = ''
        options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
    '';

    programs = {
        steam = {
            enable = true;
            protontricks.enable = true;
            extest.enable = true;
            gamescopeSession =
                {
                    enable = true;
                }
                // (lib.mkIf config.hardware.nvidia.prime.offload.enable {
                    env = {
                        # for Prime render offload on Nvidia laptops.
                        __NV_PRIME_RENDER_OFFLOAD = "1";
                        __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA_G0";
                        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
                        __VK_LAYER_NV_optimus = "NVIDIA_only";
                    };
                });
        };

        anime-game-launcher.enable = !cfg.graphics.legacyGpu; # genshin
        sleepy-launcher.enable = !cfg.graphics.legacyGpu; # zzz

        honkers-railway-launcher.enable = false;
        honkers-launcher.enable = false;

        wavey-launcher.enable = false; # Not currently playable
        anime-games-launcher.enable = false; # Not for regular use
        quartus = {
            enable = true;
            lite = {
                enable = true;
                devices = [ "cyclonev" ];
            };
            pro = {
                enable = true;
                devices = [ "cyclone10gx" ];
            };
        };
    };

    home-manager.users.${cfg.userName} = {

        home.packages = with pkgs; [
            # Hyprland / core apps
            nwg-look
            hyprshot
            # GUI apps
            pinta # Paint.NET-like image editor
            #plex-desktop # doesn't launch
            heroic
            protonvpn-gui
            slack
            prismlauncher
            #xivlauncher
            plexamp
            gtkwave
            surfer
            #bambu-studio
            tageditor
        ];

        services = {
            hypridle = {
                enable = false;
            };
        };

        programs = {
            hyprlock = {
                enable = true;
            };
            obs-studio = {
                enable = true;
                plugins = with pkgs.obs-studio-plugins; [
                    wlrobs
                ];
            };
        };
    };
}
