{
    config,
    pkgs,
    inputs,
    lib,
    ...
}:
{

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
            compositor = "niri";
        };
    };
    sops = {
        defaultSopsFile = ../../../secrets/secrets.yaml;
        defaultSopsFormat = "yaml";
        age.keyFile = "/home/${config.sidonia.userName}/.config/sops/age/keys.txt";
        secrets."hosts/gio" = {
            owner = config.sidonia.userName;
        };
    };
}
