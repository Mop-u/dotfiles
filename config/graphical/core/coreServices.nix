{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
let
    cfg = config.sidonia;
    theme = cfg.style.catppuccin;
in
lib.mkIf (cfg.graphics.enable) {

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
        XDG_CONFIG_DIRS = [ "$HOME/.config" ]; # this is missing by default, needed for ~/.config/autostart
    };

    services = {
        logind = {
            lidSwitch = "suspend-then-hibernate";
            lidSwitchExternalPower = "ignore";
            lidSwitchDocked = "ignore";
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

    home-manager.users.${cfg.userName} = {
        catppuccin.cursors = {
            enable = true;
            accent = theme.accent;
            flavor = theme.flavor;
        };

        home.file.nmAppletDropin = {
            enable = true;
            target = "/home/${cfg.userName}/.config/systemd/user/nm-applet.service.d/dropin.conf";
            text = ''
                [Service]
                Restart=on-failure
                RestartSec=3
            '';
        };

        dconf.settings = with lib.gvariant; {
            "org/gnome/desktop/interface" = {
                cursor-size = mkInt32 cfg.style.cursorSize;
            };
            "org/cinnamon/desktop/default-applications/terminal" = {
                exec = mkValue "foot";
                exec-arg = mkValue "-e";
            };
            "org/gnome/desktop/applications/terminal" = {
                exec = mkValue "foot";
                exec-arg = mkValue "-e";
            };
            "org/gnome/desktop/interface" = {
                color-scheme = if theme.flavor == "latte" then "prefer-light" else "prefer-dark";
            };
        };
        gtk =
            {
                enable = true;
            }
            // (
                if
                    (builtins.elem theme.accent [
                        "rosewater"
                        "flamingo"
                        "maroon"
                        "sky"
                        "lavender"
                    ])
                then
                    (builtins.warn
                        ''
                            The selected theme accent `${theme.accent}` is not yet supported by magnetic-catppuccin-gtk.
                            Falling back to the deprecated `gtk.catppuccin.enable` method.
                        ''
                        {
                            catppuccin = {
                                enable = true;
                                icon.enable = true;
                            };
                        }
                    )
                else
                    let
                        shade = if theme.flavor == "latte" then "light" else "dark";
                        accent =
                            {
                                # Renamed colours
                                mauve = "purple";
                                sapphire = "cyan";
                                peach = "orange";
                            }
                            .${theme.accent} or theme.accent;
                        doTweak = builtins.elem theme.flavor [
                            "frappe"
                            "macchiato"
                        ];
                    in
                    {
                        theme.name = lib.strings.concatStringsSep "-" (
                            [
                                "Catppuccin"
                                "GTK"
                                (cfg.lib.capitalize accent)
                                (cfg.lib.capitalize shade)
                            ]
                            ++ (lib.optional doTweak (cfg.lib.capitalize theme.flavor))
                        );
                        theme.package =
                            (pkgs.magnetic-catppuccin-gtk.overrideAttrs {
                                src = inputs.magnetic-catppuccin-gtk;
                            }).override
                                {
                                    inherit shade;
                                    accent = [ accent ];
                                    tweaks = lib.optional doTweak theme.flavor;
                                };
                        iconTheme.name = "Papirus";
                        iconTheme.package = pkgs.catppuccin-papirus-folders.override {
                            flavor = theme.flavor;
                            accent = theme.accent;
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
            mpv # video player
            floorp # browser
            dconf-editor # view gsettings stuff
            gsettings-desktop-schemas
            ungoogled-chromium
            ffmpegthumbnailer
            webp-pixbuf-loader
            (nemo-with-extensions.overrideAttrs { extraNativeBuildInputs = [ pkgs.gvfs ]; })
            brightnessctl
        ];

        xdg = {
            mimeApps.enable = true;
            mimeApps.defaultApplications =
                let
                    browser = "floorp.desktop";
                    imageViewer = "qimgv.desktop";
                    fileExplorer = "nemo.desktop";
                in
                {
                    "text/html" = browser;
                    "x-scheme-handler/http" = browser;
                    "x-scheme-handler/https" = browser;
                    "x-scheme-handler/about" = browser;
                    "x-scheme-handler/unknown" = browser;
                    "image/jpg" = imageViewer;
                    "image/jpeg" = imageViewer;
                    "image/png" = imageViewer;
                    "image/bmp" = imageViewer;
                    "image/gif" = imageViewer;
                    "image/webp" = imageViewer;
                    "image/x-sony-arw" = imageViewer;
                    "inode/directory" = fileExplorer;
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
