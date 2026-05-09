{ config, pkgs, ... }:

{
    imports = [
        ./hardware-configuration.nix
    ];

    networking.hostName = "shizuka";

    catppuccin = {
        enable = true;
        flavor = "mocha";
        accent = "lavender";
    };
    sidonia = {
        userName = "hoshijiro";
        ssh.pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGebQDOjFJrLRI/kxToxRVVYZo8GQWhYy/TW/dXoYcQn hoshijiro@shizuka";
        services.distributedBuilds.client.enable = false;
        desktop = {
            enable = true;
            compositor = "niri";
        };
        geolocation.enable = true;
        text.comicCode.enable = true;
        isLaptop = true;
    };

    services.xserver.xkb.layout = "gb,us";

    system.stateVersion = "25.05";
    programs.kdeconnect.enable = true;
    home-manager.users.${config.sidonia.userName} = {
        home.packages = [
            pkgs.pciutils
            pkgs.mesa-demos
        ];
        wayland.desktopManager.sidonia.keybinds = [
            {
                name = "Bemenu (Discrete GPU)";
                mod = [
                    "Super"
                    "Shift"
                ];
                key = "O";
                exec = "DRI_PRIME=1 $(bemenu-run)";
            }
        ];
        services.shikane = {
            enable = true;
            settings.profile = [
                {
                    name = "Undocked";
                    output = [
                        {
                            enable = true;
                            search = "n=eDP-1";
                            scale = 1.0;
                            mode = "1920x1080@60.03";
                            position = "0,0";
                        }
                    ];
                }
            ];
        };
    };
}
