{ inputs, config, pkgs, target, ... }:
{

    nixpkgs.overlays = [
        (final: prev: {
            hyprland = (inputs.hyprland.packages.${pkgs.system}.hyprland.override{legacyRenderer=target.legacyGpu;});
        })
    ];

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
        goxlr-utility.enable = true;
        gvfs.enable = true; # Mount, trash, and other functionalities
        tumbler.enable = true; # Thumbnail support for images
    };

    nixpkgs.config.permittedInsecurePackages = [
        "openssl-1.1.1w"  # for sublime4 & sublime-merge :(
    ]; 

    # enable virtual camera for OBS
    boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    boot.extraModprobeConfig = ''
        options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
    '';

    programs = {
        seahorse.enable = true;
        hyprland = {
            enable = true;
            portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
        };
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

    home-manager.users.${target.userName} = let
        hyprswitchConf = "/home/${target.userName}/.config/hypr/hyprswitch.css";
        cursorSize = {
            gtk = "30";
            hypr = "30";
        };
        borderSize = "2";
        rounding = "10";
        opacity = rec {
            hex = "d9";
            dec = ((inputs.nix-colors.lib.conversions.hexToDec hex)+0.0) / 255.0;
        };
    in {
        home = {
            username = target.userName;
            homeDirectory = "/home/${target.userName}";
            stateVersion = target.stateVer;
        };

        catppuccin = {
            enable = true;
            accent = target.catppuccin.accent;
            flavor = target.catppuccin.flavor;
            pointerCursor = {
                enable = true;
                accent = target.catppuccin.accent;
                flavor = target.catppuccin.flavor;
            };
        };
        dconf.settings = {
            "org/gnome/desktop/interface" = {
                cursor-size = inputs.home-manager.lib.hm.gvariant.mkInt32 cursorSize.gtk;
            };
        };
        gtk.enable = true;
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
            hyprcursor
            networkmanagerapplet
            pwvucontrol
            qpwgraph
            inputs.hyprswitch.packages.${pkgs.system}.default # hyprswitch
            dconf-editor # for debugging gtk being gtk
            kdePackages.qt6ct # for qt theming
            mate.engrampa # archive manager
            inputs.spacedrive.packages.${pkgs.system}.spacedrive # weird file manager with a ui for ants
            (nemo-with-extensions.overrideAttrs{extraNativeBuildInputs=[pkgs.gvfs];}) # normal file manager
            # GUI apps
            heroic
            vscodium
            sublime4
            sublime-merge
            teams-for-linux
            slack
            floorp
            discord
            vesktop
            prismlauncher
            xivlauncher
            plexamp
            gtkwave
            quartus-prime-lite
        ];

        services = {
            dunst = {
                enable = true;
                catppuccin.enable = true;
            };
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

        home.file.hyprswitch = {
            enable = true;
            executable = false;
            target = hyprswitchConf;
            text = ''
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
                    color: #${target.catppuccin.highlight.hex};
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

                window {
                    font-size: 18px;
                    color: #${target.catppuccin.text.hex};
                    border-radius: ${rounding}px;
                    background-color: #${target.catppuccin.base.hex}${opacity.hex};
                    border: ${borderSize}px solid #${target.catppuccin.highlight.hex};
                    opacity: initial;
                }
            '';
        };
        home.file.vesktop = {
            enable = target.helper.isInstalled pkgs.vesktop;
            executable = false;
            target = "/home/${target.userName}/.config/vesktop/settings/quickCss.css";
            text = ''
                @import url("https://catppuccin.github.io/discord/dist/catppuccin-${target.catppuccin.flavor}.theme.css");
                @import url("https://catppuccin.github.io/discord/dist/catppuccin-${target.catppuccin.flavor}-${target.catppuccin.accent}.theme.css");
            '';
        };

        programs = {
            bemenu = {
                enable = true;
            };
            hyprlock = {
                enable = true;
            };
            foot = {
                enable = true;
                catppuccin.enable = true;
                settings = {
                    # https://codeberg.org/dnkl/foot/src/branch/master/foot.ini
                    main.dpi-aware = "yes";
                    main.font = "monospace:size=${if target.smallTermFont then "7" else "8"}";
                    colors.alpha = builtins.toString opacity.dec;
                };
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
            waybar = {
                enable = true;
                package = inputs.waybar.packages.${pkgs.system}.waybar;
                catppuccin.enable = true;
                settings.mainBar = {
                    layer = "top";
                    position = "top";
                    spacing = 16;
                    modules-left = [
                        "hyprland/workspaces"
                    ];
                    modules-center = [
                        "hyprland/window" # window title
                    ];
                    modules-right = [
                        "clock"             # date & time
                        "hyprland/language" # keyboard region
                        "battery"           # laptop battery state
                        "wireplumber"       # audio
                        "tray"              # system tray
                    ];

                    "hyprland/window" = {
                        format = "<b>{class}</b> {title}";
                        separate-outputs = true;
                        icon = true;
                    };

                    "hyprland/language".format = "   {}";

                    clock = {
                        format = "   {:%H:%M}";
                        format-alt = "   {:%A, %B %d, %Y (%R)}";
                        tooltip-format = "<tt><small>{calendar}</small></tt>";
                        calendar = {
                            mode = "year";
                            mode-mon-col = 3;
                            weeks-pos = "right";
                            on-scroll = 1;
                            format = {
                                months   = "<span color='#${target.catppuccin.text.hex}'><b>{}</b></span>";
                                days     = "<span color='#${target.catppuccin.subtext0.hex}'><b>{}</b></span>";
                                weeks    = "<span color='#${target.catppuccin.overlay0.hex}'><b>W{}</b></span>";
                                weekdays = "<span color='#${target.catppuccin.overlay0.hex}'><b>{}</b></span>";
                                today    = "<span color='#${target.catppuccin.highlight.hex}'><b><u>{}</u></b></span>";
                            };
                        };
                        actions = {
                            on-click-right    = "mode";        # Switch calendar mode between year/month
                            on-click-forward  = "tz_up";       # Switch to the next provided time zone
                            on-click-backward = "tz_down";     # Switch to the previous provided time zone
                            on-scroll-up      = "shift_up";    # Switch to the previous calendar month/year
                            on-scroll-down    = "shift_down";  # Switch to the previous calendar month/year
                            on-click-middle   = "shift_reset"; # Switch to current calendar month/year
                        };
                    };

                    battery = {
                        format = "{icon}  {capacity}%";
                        format-icons = [" " " " " " " " " "];
                        states = {
                            warning = 30;
                            critical = 15;
                        };
                    };

                    wireplumber = {
                        format = "{icon}  {volume}%";
                        format-muted = " ";
                        format-icons = [" " " " " "];
                        on-click = "pwvucontrol";
                    };

                    tray = {
                        spacing = 8;
                        reverse-direction = false;
                    };
                };
                style = ''
                    @define-color accent @${target.catppuccin.accent};
                    #workspaces button {
                        color: @subtext0;
                        background-color: @base;
                    }
                    #workspaces button.urgent {
                        color: @text;
                        font-weight: bold;
                    }
                    #workspaces button.active {
                        background-color: @surface0;
                        color: @accent;
                        font-weight: bold;
                    }
                    #tray {
                        margin-right: 12;
                    }
                '';
            };
        };
        wayland.windowManager.hyprland = {
            enable = true;
            catppuccin.enable = true;
            settings = {
                exec-once = [
                    "dunst &"
                    "hyprswitch init --show-title --custom-css '${hyprswitchConf}' &"
                    "waybar &"
                    "nm-applet &"
                    "blueman-applet &"
                    "goxlr-daemon &"
                ];

                monitor = {
                    kaoru = [
                        "eDP-1,highres,0x0,1.333333,bitdepth,10"
                        "desc:Lenovo Group Limited P40w-20,highres,auto-left,1.066667,bitdepth,10"
                        ",highres,auto-left,1"
                    ];
                    yure = [
                        "LVDS-1,highres,0x0,1"
                        ",highres,auto,1"
                    ];
                }.${target.hostName} or ",highres,auto,1";

                xwayland = {
                    force_zero_scaling = true;
                };
                
                env = [
                    # Apply system theming to bemenu
                    "BEMENU_OPTS,-nciwl '16 down' --single-instance --border ${borderSize} --border-radius ${rounding} --tb '##${target.catppuccin.base.hex}${opacity.hex}' --fb '##${target.catppuccin.base.hex}${opacity.hex}' --nb '##${target.catppuccin.base.hex}${opacity.hex}' --ab '##${target.catppuccin.base.hex}${opacity.hex}' --hb '##${target.catppuccin.base.hex}${opacity.hex}' --tf '##${target.catppuccin.highlight.hex}' --ff '##${target.catppuccin.text.hex}' --nf '##${target.catppuccin.text.hex}' --af '##${target.catppuccin.text.hex}' --hf '##${target.catppuccin.highlight.hex}' --bdr '##${target.catppuccin.highlight.hex}' --width-factor 0.33 --fn '${target.comicCode.name}'"
                    # hyprswitch options
                    "WORKSPACES_PER_ROW,3"

                    # XDG specific #
                    "XDG_SESSION_TYPE,wayland"
                    "XDG_SESSION_DESKTOP,Hyprland"
                    
                    # Theming specific #
                    "WLR_EGL_NO_MODIFIERS,0" # May help with multiple monitors
                    "HYPRCURSOR_SIZE,${cursorSize.hypr}"
                    "XCURSOR_SIZE,${cursorSize.gtk}"
                    
                    # Toolkit backend vars #
                    "GDK_BACKEND,wayland,x11,*"
                    "SDL_VIDEODRIVER,wayland,x11,windows"
                    "CLUTTER_BACKEND,wayland"
                    "WLR_RENDERER_ALLOW_SOFTWARE,1" # software rendering backend

                    # QT specific #
                    "QT_AUTO_SCREEN_SCALE_FACTOR,1"
                    "QT_ENABLE_HIGHDPI_SCALING,1"
                    "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
                    "QT_QPA_PLATFORM,wayland;xcb"
                    "QT_QPA_PLATFORMTHEME,qt6ct"
                    "QT_STYLE_OVERRIDE,kvantum"

                    # App specific #
                    "MOZ_ENABLE_WAYLAND,1"
                    "MOZ_DISABLE_RDD_SANDBOX,1"
                    "MOZ_DBUS_REMOTE,1"

                    # Gaming specific #
                    "__GL_MaxFramesAllowed,1" # Fix frame timings & input lag
                    
                    # Misc #
                    "NIXOS_OZONE_WL,1"
                    #"GDK_SCALE,1"
                    #"GDK_DPI_SCALE,1"
                ];
                # Gradients:
                general."col.active_border"         = "$accent";   # border color for the active window
                general."col.inactive_border"       = "$overlay2";   # border color for inactive windows
                general."col.nogroup_border_active" = "$maroon"; # active border color for window that cannot be added to a group (see denywindowfromgroup dispatcher)
                general."col.nogroup_border"        = "$overlay2";   # inactive border color for window that cannot be added to a group (see denywindowfromgroup dispatcher)
                
                group."col.border_active"           = "$flamingo"; # active group border color
                group."col.border_inactive"         = "$overlay2";   # inactive (out of focus) group border color
                group."col.border_locked_active"    = "$flamingo $accent 45deg"; # active locked group border color
                group."col.border_locked_inactive"  = "$overlay2";   # inactive locked group border color

                group.groupbar."col.active"         = "$flamingo"; # active group border color
                group.groupbar."col.inactive"       = "$overlay2";   # inactive (out of focus) group border color
                group.groupbar."col.locked_active"  = "$flamingo $accent 45deg"; # active locked group border color
                group.groupbar."col.locked_inactive"= "$overlay2";   # inactive locked group border color

                # Colours:
                decoration."col.shadow"          = "rgba(${target.catppuccin.crust.hex}aa)"; # shadow's color. Alpha dictates shadow's opacity.
                decoration."col.shadow_inactive" = "rgba(${target.catppuccin.crust.hex}aa)"; # inactive shadow color. (if not set, will fall back to col.shadow)
                group.groupbar.text_color        = "$text";  # controls the group bar text color
                misc."col.splash"                = "$text";  # Changes the color of the splash text (requires a monitor reload to take effect).
                misc.background_color            = "$crust"; # change the background color. (requires enabled disable_hyprland_logo)
                
                animations = {
                    enabled = true;
                    bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
                    animation = [
                        "windows, 1, 7, myBezier"
                        "windowsOut, 1, 7, default, popin 80%"
                        "border, 1, 10, default"
                        "borderangle, 1, 8, default"
                        "fade, 1, 7, default"
                        "workspaces, 1, 6, default"
                    ];
                };

                decoration = {
                    rounding = rounding;
                    active_opacity = 1.0;
                    inactive_opacity = 1.0;
                    drop_shadow = !target.legacyGpu;
                    shadow_range = 12;
                    shadow_render_power = 2;
                    blur = {
                        enabled = !target.legacyGpu;
                        size = 3;
                        passes = 1;
                        vibrancy = 0.1696;
                    };
                };

                general = {
                    gaps_in = 5;
                    gaps_out = 20;
                    border_size = borderSize;
                    resize_on_border = false;
                    allow_tearing = true;
                    layout = "dwindle";
                };

                dwindle = {
                    pseudotile = true;
                    smart_split = true;
                };

                cursor = {
                    no_hardware_cursors = true;
                    no_break_fs_vrr = false;
                    enable_hyprcursor = true;
                };

                render = {
                    direct_scanout = false; # Try turning this off if fullscreen windows/games crash instantly
                };

                opengl = {
                    nvidia_anti_flicker = false;
                    force_introspection = 0; # 0:off/1:force/2:nvidia
                };

                misc = {
                    force_default_wallpaper = 0;
                    disable_hyprland_logo = true;
                    vrr = 1;
                    mouse_move_enables_dpms = true;
                    key_press_enables_dpms = true;
                };

                input = {
                    kb_layout = target.input.keyLayout;
                    # kb_variant = 
                    # kb_model = 
                    # kb_options = 
                    # kb_rules = 
                    follow_mouse = 1;
                    sensitivity = target.input.sensitivity;
                    accel_profile = target.input.accelProfile;
                    touchpad = {
                        natural_scroll = true;
                    };
                };
                windowrulev2 = [
                    "suppressevent maximize, class:.*"
                    "bordercolor $overlay2,xwayland:1,focus:0"
                    "bordercolor $yellow,  xwayland:1,focus:1"

                    "float,                          class:(foot), title:(foot)"
                    "size 896 504,                   class:(foot), title:(foot)"
                    "move onscreen cursor -50% -50%, class:(foot), title:(foot)"

                    "float, class:(com.saivert.pwvucontrol), title:(Pipewire Volume Control)"

                    "float, class:(gtkwave),title:(gtkwave)"
                    "float, class:(ssh-askpass-sublime)"

                    ## xwaylandvideobridge specific ##
                    #"opacity 0.0 override,class:^(xwaylandvideobridge)$"
                    #"noanim,class:^(xwaylandvideobridge)$"
                    #"noinitialfocus,class:^(xwaylandvideobridge)$"
                    #"maxsize 1 1,class:^(xwaylandvideobridge)$"
                    #"noblur,class:^(xwaylandvideobridge)$"
                ];
                gestures = {
                    workspace_swipe = false;
                };
                binds = {
                    scroll_event_delay = 100;
                };
                bindrn = [
                    ",  escape, exec, hyprswitch close --kill"
                ];
                bind = [
                    "SUPERSHIFT, Return,    exec, foot"
                    "SUPERSHIFT, C,         killactive,"
                    "SUPERSHIFT, Q,         exit,"
                    "SUPER,      W,         exec, hyprswitch gui"
                    "SUPER,      V,         togglefloating,"
                    "SUPER,      P,         exec, bemenu-run"
                    "SUPER,      H,         movefocus, l"
                    "SUPER,      J,         movefocus, d"
                    "SUPER,      K,         movefocus, u"
                    "SUPER,      L,         movefocus, r"
                    "SUPERSHIFT, H,         swapwindow, l"
                    "SUPERSHIFT, J,         swapwindow, d"
                    "SUPERSHIFT, K,         swapwindow, u"
                    "SUPERSHIFT, L,         swapwindow, r"
                    "SUPERALT,   H,         resizeactive, -10    0" # resize left
                    "SUPERALT,   J,         resizeactive,   0   10" # resize down
                    "SUPERALT,   K,         resizeactive,   0  -10" # resize up
                    "SUPERALT,   L,         resizeactive,  10    0" # resize right
                    "SUPER,      mouse_down,workspace, e+1"
                    "SUPER,      mouse_up,  workspace, e-1"
                    "SUPER,      S,         togglespecialworkspace, magic"
                    "SUPERSHIFT, S,         movetoworkspace,        special:magic"
                    ",           PRINT,     exec, hyprshot -m output -m active --clipboard-only" # screenshot active monitor
                    "SUPER,      PRINT,     exec, hyprshot -m window -m active --clipboard-only" # screenshot active window
                    "SUPERSHIFT, PRINT,     exec, hyprshot -m region --clipboard-only"           # screenshot region
                ]
                ++ (
                    builtins.concatLists (
                        builtins.genList (
                            x: let
                                ws = let
                                    c = (x + 1) / 10;
                                in
                                    builtins.toString (x + 1 - (c * 10));
                            in [
                                "SUPER,          ${ws},workspace,             ${toString (x + 1)}"
                                "SUPERSHIFT,     ${ws},movetoworkspace,       ${toString (x + 1)}"
                                "SUPERCONTROL,   ${ws},movetoworkspacesilent, ${toString (x + 1)}"
                                "SUPERCONTROLALT,${ws},moveworkspacetomonitor,${toString (x + 1)} current"
                                "SUPERCONTROLALT,${ws},workspace,             ${toString (x + 1)}"
                            ]
                        )
                    10)
                );
                bindm = [
                    "SUPER, mouse:272, movewindow"
                    "SUPER, mouse:273, resizewindow"
                ];
            };
        };
    };
}
