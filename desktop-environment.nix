{ inputs, config, pkgs, ... }:
{
  security.pam.services.hyprlock = {};
  services.blueman.enable = true;

  services.displayManager = {
    sddm.enable = true;
    sddm.wayland.enable = true;
    sddm.package = pkgs.kdePackages.sddm;
    autoLogin.enable = true;
    autoLogin.user = "hazama";
    defaultSession = "hyprland";
  };

  environment.systemPackages = with pkgs; [
    nwg-look
    hyprshot
    hyprcursor
    catppuccin-cursors.frappeMauve
    networkmanagerapplet
    heroic
    sublime4
    sublime-merge
    teams-for-linux
    slack
    floorp
    ungoogled-chromium
    betterbird
    discord
    discord-ptb
    prismlauncher
    xivlauncher
    plexamp
    gtkwave
    quartus-prime-lite
  ];

  home-manager.users.hazama = {
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
  };

  home-manager.users.hazama.programs = {
    waybar = {
      enable = true;
      catppuccin.enable = true;
    };
    bemenu = {
      enable = true;
    };
    hyprlock = {
      enable = true;
    };
    kitty = {
      enable = true;
      catppuccin.enable = true;
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
	obs-backgroundremoval
	obs-pipewire-audio-capture
      ];
    };
  };

  # enable virtual camera for OBS
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
  '';
  security.polkit.enable = true;

  home-manager.users.hazama.services = {
    swaync = {
      enable = true;
    };
    hypridle = {
      enable = false;
    };
  };

  programs.hyprland = {
    enable = true;
    #package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  };

  home-manager.users.hazama.wayland.windowManager.hyprland = {
    enable = true;
    #package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    catppuccin.enable = true;
    settings = {
      exec-once = [
        "waybar &"
        "swaync &"
        "goxlr-daemon &"
        "nm-applet &"
        "blueman-applet &"
      ];
      monitor = [
        "eDP-1,highres,0x0,1.333333,bitdepth,10"
	"DP-3,highres,auto-left,1.066667,bitdepth,10"
      ];
      xwayland = {
        force_zero_scaling = true;
      };
      env = [
      	# NVIDIA #
	"LIBVA_DRIVER_NAME,nvidia" # nvidia hardware acceleration
	"GBM_BACKEND,nvidia-drm"   # force GBM backend
	"__GL_GSYNC_ALLOWED,0"
	"__GL_VRR_ALLOWED,0"
	"NVD_BACKEND,direct" # VA-API hardware video acceleration
        
	# Force NVIDIA offload for all applications #
	"__NV_PRIME_RENDER_OFFLOAD,1"
	"__NV_PRIME_RENDER_OFFLOAD_PROVIDER,NVIDIA_G0"
	"__GLX_VENDOR_LIBRARY_NAME,nvidia"
	"__VK_LAYER_NV_optimus,NVIDIA_only"

	# XDG specific #
	"XDG_SESSION_TYPE,wayland"
	"XDG_SESSION_DESKTOP,Hyprland"
	
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

	# Java specific #
	# many Java apps (such as Intellij) don't support Wayland natively and break on
	# most XWayland implementations

	# Gaming specific #
	"__GL_MaxFramesAllowed,1" # Fix frame timings & input lag
	
	# Misc #
	#"ELECTRON_ARGS=\"--enable-features=UseOzonePlatform --ozone-platform=wayland\""
	"NIXOS_OZONE_WL,1"
	#"GDK_SCALE,1"
	#"GDK_DPI_SCALE,1"
      ];
      # Gradients:
      general."col.active_border"         = "$accent"; # border color for the active window
      general."col.inactive_border"       = "$mantle"; # border color for inactive windows
      general."col.nogroup_border_active" = "$overlay2"; # active border color for window that cannot be added to a group (see denywindowfromgroup dispatcher)
      general."col.nogroup_border"        = "$mantle"; # inactive border color for window that cannot be added to a group (see denywindowfromgroup dispatcher)
      group."col.border_active"           = "$surface2"; # active group border color
      group."col.border_inactive"         = "$mantle"; # inactive (out of focus) group border color
      group."col.border_locked_active"    = "$overlay2 $accent 45deg"; # active locked group border color
      group."col.border_locked_inactive"  = "$mantle"; # inactive locked group border color
      group.groupbar."col.active"         = "$surface2"; # active group border color
      group.groupbar."col.inactive"       = "$mantle"; # inactive (out of focus) group border color
      group.groupbar."col.locked_active"  = "$overlay2 $accent 45deg"; # active locked group border color
      group.groupbar."col.locked_inactive"= "$mantle"; # inactive locked group border color

      # Colours:
      decoration."col.shadow"          = "rgba($crustAlphaee)"; # shadow's color. Alpha dictates shadow's opacity.
      decoration."col.shadow_inactive" = "rgba($crustAlphaee)"; # inactive shadow color. (if not set, will fall back to col.shadow)
      group.groupbar.text_color        = "$text"; # controls the group bar text color
      misc."col.splash"                = "$text"; # Changes the color of the splash text (requires a monitor reload to take effect).
      misc.background_color            = "$crust"; # change the background color. (requires enabled disable_hyprland_logo)

      general = {
        gaps_in = 5;
	gaps_out = 20;
	border_size = 2;
	resize_on_border = false;
	allow_tearing = true;
	layout = "dwindle";
      };

      cursor = {
        no_hardware_cursors = true;
	no_break_fs_vrr = false;
        enable_hyprcursor = true;
      };

      binds = {
        scroll_event_delay = 100;
      };

      decoration = {
        rounding = 10;
	active_opacity = 1.0;
	inactive_opacity = 1.0;
	drop_shadow = true;
	shadow_range = 4;
	shadow_render_power = 3;
	blur = {
	  enabled = true;
	  size = 3;
	  passes = 1;
	  vibrancy = 0.1696;
	};
      };
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
      dwindle = {
        pseudotile = true;
	preserve_split = true;
      };

      misc = {
        force_default_wallpaper = 0;
	disable_hyprland_logo = true;
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
      gestures = {
        workspace_swipe = false;
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
      bind = [
        "SUPERSHIFT, Return,    exec, kitty"
	"SUPERSHIFT, C,         killactive,"
	"SUPERSHIFT, Q,         exit,"
	"SUPER,      V,         togglefloating,"
	"SUPER,      P,         exec, bemenu-run -i -w -l \"16 down\""
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
      ++ (builtins.concatLists (
        builtins.genList (
	  x: let
	    ws = let
	      c = (x + 1) / 10;
	    in
	      builtins.toString (x + 1 - (c * 10));
	  in [
	    "SUPER,      ${ws}, workspace,      ${toString (x + 1)}"
	    "SUPERSHIFT, ${ws}, movetoworkspace,${toString (x + 1)}"
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
}
