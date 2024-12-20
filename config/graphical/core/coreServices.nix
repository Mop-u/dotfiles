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

        playerctld.enable = true;
    };

    programs = {
        seahorse.enable = true;
        xfconf.enable = true;
        nm-applet.enable = true; # systemd graphical-session.target
    };

    home-manager.users.${target.userName} = {
        catppuccin.cursors = {
            enable = true;
            accent = target.style.catppuccin.accent;
            flavor = target.style.catppuccin.flavor;
        };

        dconf.settings = {
            "org/gnome/desktop/interface" = {
                cursor-size = inputs.home-manager.lib.hm.gvariant.mkInt32 target.style.cursorSize.gtk;
            };
        };
        gtk = {enable = true;} // (
            if (builtins.elem target.style.catppuccin.accent [
                "rosewater"
                "flamingo"
                "maroon"
                "sky"
                "lavender"
            ]) 
            then (
                builtins.warn ''
                    The selected theme accent `${target.style.catppuccin.accent}` is not yet supported by magnetic-catppuccin-gtk.
                    Falling back to the deprecated `gtk.catppuccin.enable` method.
                '' 
                {
                    catppuccin = {
                        enable = true;
                        icon.enable = true;
                    };
                }
            )
            else let
                shade = if target.style.catppuccin.flavor == "latte" then "light" else "dark";
                accent = {
                    # Renamed colours
                    mauve     = "purple";
                    sapphire  = "cyan";
                    peach     = "orange";
                }.${target.style.catppuccin.accent} or target.style.catppuccin.accent;
                doTweak = builtins.elem target.style.catppuccin.flavor ["frappe" "macchiato"];
            in {
                theme.name = lib.strings.concatStringsSep "-" (
                    ["Catppuccin" "GTK" (target.lib.capitalize accent) (target.lib.capitalize shade)]
                    ++(if doTweak then [(target.lib.capitalize target.style.catppuccin.flavor)] else [])
                );
                theme.package = (pkgs.magnetic-catppuccin-gtk.overrideAttrs{
                    src = inputs.magnetic-catppuccin-gtk;
                }).override{
                    inherit shade;
                    accent = [accent];
                    tweaks = if doTweak then [target.style.catppuccin.flavor] else [];
                };
                iconTheme.name = "Papirus";
                iconTheme.package = pkgs.catppuccin-papirus-folders.override{
                    flavor = target.style.catppuccin.flavor;
                    accent = target.style.catppuccin.accent;
                };
            }
        );
        qt = {
            enable = true;
            style.name = "kvantum";
            platformTheme.name = "kvantum";
        };
        catppuccin.kvantum = {
            enable = true;
            apply = true;
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
            ffmpegthumbnailer
            (nemo-with-extensions.overrideAttrs{extraNativeBuildInputs=[pkgs.gvfs];})
            brightnessctl
        ];
    };
}