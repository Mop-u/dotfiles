{inputs, config, pkgs, lib, target, ... }:
{
    
    security = {
        pam.services.hyprlock = {};
        pam.services.sddm.enableGnomeKeyring = true;
        polkit.enable = true;
    };
    xdg = {
        autostart.enable = true;
        portal = {
            extraPortals = [
                pkgs.xdg-desktop-portal-gnome
            ];
        };
    };

    services.displayManager = {
        sddm.enable = true;
        sddm.wayland.enable = true;
        sddm.package = pkgs.kdePackages.sddm;
        autoLogin.enable = true;
        autoLogin.user = target.userName;
        defaultSession = "hyprland";
    };

    services = {
        blueman.enable = true;
        gvfs.enable = true; # Mount, trash, and other functionalities
        tumbler.enable = true; # Thumbnail support for images
    };

    
    # enable virtual camera for OBS
    boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    boot.extraModprobeConfig = ''
        options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
    '';

    programs = {
        seahorse.enable = true;
        steam = {
            enable = true;
            protontricks.enable = true;
            extest.enable = true;
            gamescopeSession.enable = true;
        };
        xfconf.enable = true; # for remembering thunar preferences etc.

        anime-game-launcher.enable = !target.legacyGpu; # genshin
        sleepy-launcher.enable = !target.legacyGpu; # zzz

        honkers-railway-launcher.enable = false;
        honkers-launcher.enable = false;
        
        wavey-launcher.enable = false;       # Not currently playable
        anime-games-launcher.enable = false; # Not for regular use
        anime-borb-launcher.enable = false;  # Not actively maintained
    };

    home-manager = {
        useGlobalPkgs = true;
        backupFileExtension = "backup";
    };

    home-manager.users.${target.userName} = {
        home = {
            username = target.userName;
            homeDirectory = "/home/${target.userName}";
            stateVersion = target.stateVer;
        };

        catppuccin = {
            enable = true;
            accent = target.style.catppuccin.accent;
            flavor = target.style.catppuccin.flavor;
            pointerCursor = {
                enable = true;
                accent = target.style.catppuccin.accent;
                flavor = target.style.catppuccin.flavor;
            };
        };
        dconf.settings = {
            "org/gnome/desktop/interface" = {
                cursor-size = inputs.home-manager.lib.hm.gvariant.mkInt32 target.style.cursorSize.gtk;
            };
        };
        gtk.enable = true;
        # When this deprecated catppuccin gtk theme finally rots, try magnetic-catppuccin-gtk
        gtk.catppuccin = {
            enable = true;
            icon.enable = true;
            size = "standard";
            tweaks = [ 
                #"black"
                "rimless"
                "normal"
            ];
        };
        #gtk.theme.name = "Adwaita-dark";
        qt = {
            enable = true;
            style = {
                catppuccin.enable = true;
                catppuccin.apply = true;
                name = "kvantum";
            };
            platformTheme.name = "kvantum";
        };

        home.packages = with pkgs; [
            # Hyprland / core apps
            nwg-look
            hyprshot
            networkmanagerapplet
            pwvucontrol
            qpwgraph
            dconf-editor # for debugging gtk being gtk
            kdePackages.qt6ct # for qt theming
            mate.engrampa # archive manager
            spacedrive # weird file manager with a ui for ants
            (nemo-with-extensions.overrideAttrs{extraNativeBuildInputs=[pkgs.gvfs];}) # normal file manager
            # GUI apps
            heroic
            vscodium
            teams-for-linux
            slack
            floorp
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
            blueman-applet = {
                enable = true;
            };
            gnome-keyring = {
                enable = true;
            };
        };

        programs = {
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
