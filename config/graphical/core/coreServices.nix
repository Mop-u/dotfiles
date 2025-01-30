{inputs, config, pkgs, lib, target, ... }:
{

    security = {
        pam.services = {
            sddm.enableGnomeKeyring = true;
            login.enableGnomeKeyring = true;
        };
        polkit.enable = true;
    };

    xdg = {
        terminal-exec = {
            enable = true;
            settings.default = [
                "foot.desktop"
            ];
        };
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
            autoLogin.enable = false;
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
                cursor-size = lib.gvariant.mkInt32 target.style.cursorSize.gtk;
            };
            "org/cinnamon/desktop/default-applications/terminal" = {
                #exec = lib.gvariant.mkValue "${pkgs.foot}/bin/foot";
                exec = lib.gvariant.mkValue "foot";
                exec-arg = lib.gvariant.mkValue "-e";
            };
            "org/gnome/desktop/applications/terminal" = {
                exec = lib.gvariant.mkValue "foot";
                exec-arg = lib.gvariant.mkValue "-e";
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
            qimgv
            (stdenv.mkDerivation {
                pname = "qtraw";
                version = "1.1";

                src = fetchFromGitLab {
                    owner = "mardy";
                    repo = "qtraw";
                    rev = "e75153f9d914f757d29959775bae7931303781e7";
                    hash = "sha256-tN9aVb7yCti1j/Jg+B73wo1W5ewSt4oR8aOswjF3Zew=";
                };

                nativeBuildInputs = [
                    libsForQt5.qt5.wrapQtAppsHook
                    libsForQt5.qmake
                    pkg-config
                    libraw
                ];

                buildInputs = [
                    libsForQt5.qt5.qtbase
                ];

                #QT_INSTALL_PLUGINS = "";

                #dontWrapQtApps = true;
            })
            mpv           # video player
            floorp        # browser
            dconf-editor  # view gsettings stuff
            gsettings-desktop-schemas
            ungoogled-chromium
            ffmpegthumbnailer
            webp-pixbuf-loader
            (nemo-with-extensions.overrideAttrs{extraNativeBuildInputs=[pkgs.gvfs];})
            brightnessctl
        ];

        xdg = {
            mimeApps.enable = true;
            mimeApps.defaultApplications = let
                browser = "floorp.desktop";
                imageViewer = "qimgv.desktop";
                fileExplorer = "nemo.desktop";
            in {
                "text/html"                = browser;
                "x-scheme-handler/http"    = browser;
                "x-scheme-handler/https"   = browser;
                "x-scheme-handler/about"   = browser;
                "x-scheme-handler/unknown" = browser;
                "image/jpg"        = imageViewer;
                "image/jpeg"       = imageViewer;
                "image/png"        = imageViewer;
                "image/bmp"        = imageViewer;
                "image/gif"        = imageViewer;
                "image/webp"       = imageViewer;
                "image/x-sony-arw" = imageViewer;
                "inode/directory"                  = fileExplorer;
                "application/x-gnome-saved-search" = fileExplorer;
            };
            mimeApps.associations.added = {
                "image/jpg" = "qimgv.desktop";
            };
            desktopEntries = {

            };
        };
    };
}