{inputs, config, pkgs, lib, target, ... }:
{

    nixpkgs.overlays = [
        (final: prev: {
            hyprland = (inputs.hyprland.packages.${pkgs.system}.hyprland.override{legacyRenderer=target.legacyGpu;});
        })
    ];

    programs.hyprland = {
        enable = true;
        portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
    };

    home-manager.users.${target.userName} = {
        home.packages = [pkgs.hyprcursor];
        wayland.windowManager.hyprland = {
            enable = true;
            catppuccin.enable = true;
            systemd.enable = true;
            systemd.enableXdgAutostart = true;
            xwayland.enable = true;
            settings = {
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
                    # XDG specific #
                    "XDG_SESSION_TYPE,wayland"
                    "XDG_SESSION_DESKTOP,Hyprland"
                    
                    # Theming specific #
                    "WLR_EGL_NO_MODIFIERS,0" # May help with multiple monitors
                    "HYPRCURSOR_SIZE,${target.style.cursorSize.hypr}"
                    "XCURSOR_SIZE,${target.style.cursorSize.gtk}"
                    
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
                decoration."col.shadow"          = "rgba(${target.style.catppuccin.crust.hex}aa)"; # shadow's color. Alpha dictates shadow's opacity.
                decoration."col.shadow_inactive" = "rgba(${target.style.catppuccin.crust.hex}aa)"; # inactive shadow color. (if not set, will fall back to col.shadow)
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
                    rounding = target.window.rounding;
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
                    border_size = target.window.borderSize;
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

                    "float, class:(com.saivert.pwvucontrol), title:(Pipewire Volume Control)"

                    "float, class:(gtkwave),title:(gtkwave)"

                    "float,                          class:.*, title:(Open File)"
                    "size ${target.window.float.wh}, class:.*, title:(Open File)"
                    
                    "float,                          class:.*, title:(Save File)"
                    "size ${target.window.float.wh}, class:.*, title:(Save File)"

                    "float,                          class:.*, title:(Select Folder)"
                    "size ${target.window.float.wh}, class:.*, title:(Select Folder)"

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
                bindel = [
                    ", XF86AudioRaiseVolume,  exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@   5%+"
                    ", XF86AudioLowerVolume,  exec, wpctl set-volume      @DEFAULT_AUDIO_SINK@   5%-"
                    ", XF86AudioMute,         exec, wpctl set-mute        @DEFAULT_AUDIO_SINK@   toggle"
                    ", XF86AudioMicMute,      exec, wpctl set-mute        @DEFAULT_AUDIO_SOURCE@ toggle"

                    ", XF86MonBrightnessUp,   exec, brightnessctl s 10%+"
                    ", XF86MonBrightnessDown, exec, brightnessctl s 10%-"
                ];
                bindl = [
                    ", XF86AudioNext,  exec, playerctl next"
                    ", XF86AudioPause, exec, playerctl play-pause"
                    ", XF86AudioPlay,  exec, playerctl play-pause"
                    ", XF86AudioPrev,  exec, playerctl previous"
                ];
                bind = [
                    "SUPERSHIFT, C,         killactive,"
                    "SUPERSHIFT, Q,         exit,"
                    "SUPER,      V,         togglefloating,"
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