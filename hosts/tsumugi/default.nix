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
        ./arr.nix
        ./iperf.nix
        ./lancache.nix
        ./minecraft.nix
        ./networkMounts.nix
        ./openssh.nix
        ./reverseProxy.nix
        ./ups.nix
    ];
    sops.secrets."tsumugi/cacheKey" = {};
    sidonia = {
        userName = "shiraui";
        stateVer = "24.05";
        style.catppuccin.flavor = "macchiato";
        style.catppuccin.accent = "teal";
        services.kmscon.enable = true;
        services.distributedBuilds = {
            host = {
                enable = true;
                signing.pubKey = "tsumugi:uwel3yZCdN+VwrqZHk+sPD3HtyhgbLISCqUxVnY1uAI=";
                signing.privKeyPath = config.sops.secrets."tsumugi/cacheKey".path;
                ssh.pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIBidxqGI8eFmemPDR2FAGpApxR4tXgSD6m893JchS2+";
                hostNames = [
                    "10.0.4.2"
                    "tsumugi.local"
                ];
            };
        };
    };
}
