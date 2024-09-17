{inputs, config, pkgs, lib, target, ... }:
{
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
        dconf-editor # for debugging gtk being gtk
        kdePackages.qt6ct # for qt theming
        mate.engrampa # archive manager
        spacedrive # weird file manager with a ui for ants
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
}
