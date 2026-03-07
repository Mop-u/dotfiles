{ config, pkgs, ... }:

{
    imports = [
        # Include the results of the hardware scan.
        ./hardware-configuration.nix
    ];

    # Bootloader.
    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/sda";
    boot.loader.grub.useOSProber = true;

    networking.hostName = "shizuka"; # Define your hostname.

    catppuccin = {
        enable = true;
        flavor = "mocha";
        accent = "lavender";
    };
    sidonia = {
        userName = "hoshijiro";
        ssh.pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGebQDOjFJrLRI/kxToxRVVYZo8GQWhYy/TW/dXoYcQn hoshijiro@shizuka";
        desktop = {
            enable = true;
            compositor = "hyprland";
        };
        geolocation.enable = true;
        text.comicCode.enable = true;
        input.keyLayout = "gb";
        isLaptop = true;
    };

    system.stateVersion = "25.05"; # Did you read the comment?
    programs.kdeconnect.enable = true;
    home-manager.users.${config.sidonia.userName}.services.shikane = {
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
}
