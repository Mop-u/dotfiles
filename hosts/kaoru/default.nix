{
    config,
    pkgs,
    inputs,
    lib,
    ...
}:
{
    imports = [
        ./hardware-configuration.nix
        ./networkMounts.nix
        ./virtualbox.nix
    ];

    home-manager.users.${config.sidonia.userName}.imports = [ ./home.nix ];

    networking.hostName = "kaoru";
    nix.settings = {
        keep-outputs = true;
        max-jobs = 4;
        cores = 8; # avoid thermal throttling
    };
    services = {
        supergfxd.enable = true;
        asusd = {
            enable = true;
            enableUserService = true;
        };
    };
    catppuccin = {
        enable = true;
        flavor = "mocha";
        accent = "mauve";
    };

    system.stateVersion = "23.11";
    programs.kdeconnect.enable = true;
    sidonia = {
        userName = "hazama";
        ssh.pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINfNV3Z/LI/4ItskdADIC4JWqfW3Wae4TRK/Ahos5TgB hazama@kaoru";
        text.comicCode.enable = true;
        services.distributedBuilds.client.enable = true;
        isLaptop = true;
        geolocation.enable = true;
        desktop = {
            enable = true;
            compositor = "hyprland";
            shell = "noctalia";
            monitors = [
                {
                    name = "eDP-1";
                    resolution.x = 2560;
                    resolution.y = 1600;
                    resolution.hz = 165.00400;
                    scale = 1.333333;
                    position = "6720x0";
                    bitdepth = 10;
                }
                {
                    name = "desc:Lenovo Group Limited P40w-20 V9095052";
                    resolution.x = 5120;
                    resolution.y = 2160;
                    resolution.hz = 74.97900;
                    scale = 1.066667;
                    position = "0x0";
                    bitdepth = 10;
                }
                {
                    name = "desc:BNQ ZOWIE XL LCD JAG03521SL0";
                    resolution.x = 1920;
                    resolution.y = 1080;
                    resolution.hz = 60;
                    scale = 1.0; # 0.833333;
                    position = "4800x400";
                }
            ];
        };
    };
    sops = {
        defaultSopsFile = ../../secrets/secrets.yaml;
        defaultSopsFormat = "yaml";
        age.keyFile = "/home/${config.sidonia.userName}/.config/sops/age/keys.txt";
        secrets."hosts/gio" = {
            owner = config.sidonia.userName;
        };
    };
}
