{ inputs, config, pkgs, sysConf, ... }:
{

    security = {
        pam.services.hyprlock = {};
        polkit.enable = true;
    };

    services.displayManager = {
        sddm.enable = true;
        sddm.wayland.enable = true;
        sddm.package = pkgs.kdePackages.sddm;
        autoLogin.enable = true;
        autoLogin.user = sysConf.userName;
        defaultSession = "hyprland";
    };

    services = {
        blueman.enable = true;
        goxlr-utility.enable = true;
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
        hyprland = {
            enable = true;
            package = inputs.hyprland.packages.${pkgs.system}.hyprland;
            portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
        };
        steam = {
            enable = true;
            protontricks.enable = true;
            extest.enable = true;
            gamescopeSession.enable = true;
        };

        anime-game-launcher.enable = true; # genshin
        sleepy-launcher.enable = true; # zzz

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

    home-manager.users.${sysConf.userName} = 
    let
    hyprswitchConf = "/home/${sysConf.userName}/.config/hypr/hyprswitch.css";
        theme = (import ./catppuccin.nix).catppuccin.frappe.hex;
        accent = theme.mauve;
        borderSize = "2";
        rounding = "10";
    in {
        home = {
            username = sysConf.userName;
            homeDirectory = "/home/${sysConf.userName}";
            stateVersion = sysConf.stateVer;
        };

        catppuccin = {
            enable = true;
            accent = "mauve";
            flavor = "frappe";
            pointerCursor = {
                enable = true;
                accent = "mauve";
                flavor = "frappe";
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
        qt.enable = true;
        qt.style = {
            catppuccin.enable = true;
            catppuccin.apply = true;
            name = "kvantum";
        };
        qt.platformTheme.name = "kvantum";

        home.packages = with pkgs; [
            # Hyprland / core apps
            nwg-look
            hyprshot
            hyprcursor
            networkmanagerapplet
            pavucontrol
            inputs.hyprswitch.packages.${pkgs.system}.default # hyprswitch
            # GUI apps
            heroic
            vscodium
            sublime4
            sublime-merge
            teams-for-linux
            slack
            floorp
            ungoogled-chromium
            discord
            discord-ptb
            prismlauncher
            xivlauncher
            plexamp
            gtkwave
            quartus-prime-lite
        ];

        services = {
            swaync = {
                enable = true;
            };
            hypridle = {
                enable = false;
            };
            blueman-applet = {
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
                    color: #${accent};
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
                    color: #${theme.text};
                    border-radius: ${rounding}px;
                    background-color: #${theme.base}ee;
                    border: ${borderSize}px solid #${accent};
                    opacity: initial;
                }
            '';
        };

        programs = {
            bemenu = {
                enable = true;
            };
            hyprlock = {
                enable = true;
            };
            kitty = {
                enable = true;
                catppuccin.enable = true;
                settings = {
                    background_opacity = "0.9333"; # Roughly 0xee equivalent
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
                                months   = "<span color='#${theme.text}'><b>{}</b></span>";
                                days     = "<span color='#${theme.subtext0}'><b>{}</b></span>";
                                weeks    = "<span color='#${theme.overlay0}'><b>W{}</b></span>";
                                weekdays = "<span color='#${theme.overlay0}'><b>{}</b></span>";
                                today    = "<span color='#${accent}'><b><u>{}</u></b></span>";
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
                        on-click = "pavucontrol";
                    };

                    tray = {
                        spacing = 8;
                        reverse-direction = false;
                    };
                };
                style = ''
                    @define-color accent @mauve;
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
            package = inputs.hyprland.packages.${pkgs.system}.hyprland;
            catppuccin.enable = true;
            settings = {
                exec-once = [
                    "swaync &"
                    "hyprswitch init --show-title --custom-css '${hyprswitchConf}' &"
                    "waybar &"
                    "nm-applet &"
                    "blueman-applet &"
                    "goxlr-daemon &"
                ];
                monitor = [
                    "eDP-1,highres,0x0,1.333333,bitdepth,10"
                    "DP-3,highres,auto-left,1.066667,bitdepth,10"
                ];
                xwayland = {
                    force_zero_scaling = true;
                };
                env = [
                    # Apply system theming to bemenu
                    "BEMENU_OPTS,-nciwl '16 down' --single-instance --border ${borderSize} --border-radius ${rounding} --tb '##${theme.base}ee' --fb '##${theme.base}ee' --nb '##${theme.base}ee' --ab '##${theme.base}ee' --hb '##${theme.base}ee' --tf '##${accent}' --ff '##${theme.text}' --nf '##${theme.text}' --af '##${theme.text}' --hf '##${accent}' --bdr '##${accent}' --width-factor 0.33 --fn 'Comic Code'"
                    # hyprswitch options
                    "WORKSPACES_PER_ROW,3"

                    # XDG specific #
                    "XDG_SESSION_TYPE,wayland"
                    "XDG_SESSION_DESKTOP,Hyprland"

                    # Electron specific #
                    #"DEFAULT_BROWSER,${pkgs.floorp}/bin/floorp"
                    
                    # Theming specific #
                    "WLR_EGL_NO_MODIFIERS,0" # May help with multiple monitors
                    "HYPRCURSOR_SIZE,32"
                    "XCURSOR_SIZE,32"
                    
                    # Toolkit backend vars #
                    "QT_QPA_PLATFORM,wayland;xcb" # "wayland;xcb"
                    "GDK_BACKEND,wayland,x11,*"
                    "SDL_VIDEODRIVER,wayland,x11,windows"
                    "CLUTTER_BACKEND,wayland"
                    "WLR_RENDERER_ALLOW_SOFTWARE,1" # software rendering backend

                    # QT specific #
                    "QT_AUTO_SCREEN_SCALE_FACTOR,1" # https://doc.qt.io/qt-5/highdpi.html
                    "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"

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
                decoration."col.shadow"          = "rgba(${theme.crust}ee)"; # shadow's color. Alpha dictates shadow's opacity.
                decoration."col.shadow_inactive" = "rgba(${theme.crust}ee)"; # inactive shadow color. (if not set, will fall back to col.shadow)
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
                    drop_shadow = false;
                    shadow_range = 4;
                    shadow_render_power = 3;
                    blur = {
                        enabled = false;
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
                    preserve_split = true;
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
                    kb_layout = "us";
                    # kb_variant = 
                    # kb_model = 
                    # kb_options = 
                    # kb_rules = 
                    follow_mouse = 1;
                    sensitivity = -0.75;
                    touchpad = {
                        natural_scroll = true;
                    };
                };
                windowrulev2 = [
                    "suppressevent maximize, class:.*"
                    "bordercolor $subtext1,xwayland:1,focus:0"
                    "bordercolor $subtext1 $accent 45deg,xwayland:1,focus:1"
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
                    "SUPERSHIFT, Return,    exec, kitty"
                    "SUPERSHIFT, C,         killactive,"
                    "SUPERSHIFT, Q,         exit,"
                    "SUPER,      W,         exec, hyprswitch gui"
                    "SUPER,      V,         togglefloating,"
                    "SUPER,      P,         exec, bemenu-run"
                    "SUPER,      H,         movefocus, l"
                    "SUPER,      J,         movefocus, d"
                    "SUPER,      K,         movefocus, u"
                    "SUPER,      L,         movefocus, r"
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
