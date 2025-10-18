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
        ./arr
        ./gameServers
        ./transmission.nix
        ./iperf.nix
        ./lancache.nix
        ./networkMounts.nix
        ./openssh.nix
        ./reverseProxy.nix
    ];
    networking.hostName = "tsumugi";
    nix.settings.keep-outputs = true;
    nix.settings.keep-derivations = true;
    sidonia = {
        userName = "shiraui";
        stateVer = "24.05";
        style.catppuccin.flavor = "macchiato";
        style.catppuccin.accent = "teal";
        services.kmscon.enable = false;
        services.distributedBuilds = {
            host = {
                enable = true;
                signing.pubKey = "tsumugi:uwel3yZCdN+VwrqZHk+sPD3HtyhgbLISCqUxVnY1uAI=";
                signing.privKeyPath = config.sops.secrets."tsumugi/cacheKey.pem".path;
                ssh.pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIBidxqGI8eFmemPDR2FAGpApxR4tXgSD6m893JchS2+";
                hostNames = [
                    "10.0.4.2"
                    "tsumugi.local"
                ];
            };
        };
    };
    sops = {
        defaultSopsFile = ../../secrets/secrets.yaml;
        defaultSopsFormat = "yaml";
        age.keyFile = "/home/shiraui/.config/sops/age/keys.txt";
        secrets."tsumugi/cacheKey.pem" = { };
    };
}
