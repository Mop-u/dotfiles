{inputs, config, pkgs, lib, target, ... }:
{

    security = {
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

    environment.sessionVariables = {
        XDG_CONFIG_DIRS = ["$HOME/.config"]; # this is missing by default, needed for ~/.config/autostart
    };

    services = {
        displayManager = {
            sddm.enable = true;
            sddm.wayland.enable = true;
            sddm.package = pkgs.kdePackages.sddm;
            autoLogin.enable = true;
            autoLogin.user = target.userName;
            defaultSession = "hyprland";
        };

        gvfs.enable = true; # Mount, trash, and other functionalities
        
        tumbler.enable = true; # Thumbnail support for images

        blueman.enable = true;
    };

    programs = {
        seahorse.enable = true;
        xfconf.enable = true;
        nm-applet.enable = true; # systemd graphical-session.target
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

        services = {
            blueman-applet.enable = true; # systemd graphical-session.target
            gnome-keyring.enable = true;
        };

        home.packages = with pkgs; [
            # Hyprland / core apps
            pwvucontrol
            qpwgraph
            mate.engrampa # archive manager
            (nemo-with-extensions.overrideAttrs{extraNativeBuildInputs=[pkgs.gvfs];})
        ];
    };
}