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
    ];
    networking.hostName = "yuhata";
    sidonia = {
        userName = "midorikawa";
        stateVer = "25.05";
        style.catppuccin = {
            flavor = "macchiato";
            accent = "lavender";
        };
        ssh.pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJDCi7RR4mckEAgC7mVNFHNvzTg3JwvcKYrYKXqf1Hew midorikawa@yuhata";
        services.distributedBuilds.client.enable = true;
        geolocation.enable = true;
        graphics.enable = true;
        text.comicCode.enable = true;
        tweaks.withBehringerAudioInterface = true;
    };
    sops = {
        defaultSopsFile = ../../secrets/secrets.yaml;
        defaultSopsFormat = "yaml";
        age.keyFile = "/home/midorikawa/.config/sops/age/keys.txt";
    };
}
