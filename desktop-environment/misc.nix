{inputs, config, pkgs, lib, target, ... }:
{
    
    security = {
        pam.services.hyprlock = {};
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
            gamescopeSession.enable = true;
        };

        anime-game-launcher.enable = !target.legacyGpu; # genshin
        sleepy-launcher.enable = !target.legacyGpu; # zzz

        honkers-railway-launcher.enable = false;
        honkers-launcher.enable = false;
        
        wavey-launcher.enable = false;       # Not currently playable
        anime-games-launcher.enable = false; # Not for regular use
        anime-borb-launcher.enable = false;  # Not actively maintained
    };


    home-manager.users.${target.userName} = {

        home.packages = with pkgs; [
            # Hyprland / core apps
            nwg-look
            hyprshot
            dconf-editor # for debugging gtk being gtk
            kdePackages.qt6ct # for qt theming
            # GUI apps
            heroic
            vscodium
            teams-for-linux
            slack
            floorp
            ungoogled-chromium
            prismlauncher
            xivlauncher
            plexamp
            gtkwave
            quartus-prime-lite
        ];

        services = {
            hypridle = {
                enable = false;
            };
        };

        programs = {
            zsh = {
                enable = true;
            };
            bash = {
                enable = true;
            };
            zoxide = {
                enable = true;
            };
            bat = {
                enable = true;
                catppuccin.enable = true;
            };
            hyprlock = {
                enable = true;
            };
            neovim = {
                enable = true;
                defaultEditor = true;
                catppuccin.enable = true;
            };
            btop = {
                enable = true;
                catppuccin.enable = true;
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
