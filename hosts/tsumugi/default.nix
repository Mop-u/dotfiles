{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ../../common/os/services/openssh.nix
    ./arr
    ./gameServers
    ./hardware-configuration.nix
    ./iperf.nix
    ./networkMounts.nix
    ./transmission.nix
  ];
  networking.hostName = "tsumugi";
  nix.settings = {
    keep-outputs = true;
    keep-derivations = true;
  };
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "teal";
  };
  system.stateVersion = "24.05";
  sidonia = {
    userName = "shiraui";
    netbird.oneTimeKey = "55E39BBC-B480-4272-9577-B7046E432A3F";
    services.distributedBuilds = {
      host = {
        enable = true;
        signing.pubKey = "tsumugi:uwel3yZCdN+VwrqZHk+sPD3HtyhgbLISCqUxVnY1uAI=";
        signing.privKeyPath = config.sops.secrets."tsumugi/cacheKey.pem".path;
        ssh.pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIBidxqGI8eFmemPDR2FAGpApxR4tXgSD6m893JchS2+";
        hostNames = [ "tsumugi.sidon.ia" ];
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
