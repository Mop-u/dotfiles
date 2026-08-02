{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    ../../common/os/services/openssh.nix
    ./hardware-configuration.nix
    ./netbird.nix
    ./proxies.nix
  ];
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "maroon";
  };
  system.stateVersion = "26.05";
  sidonia = {
    userName = "hiyama";
    ssh.pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMh1dUFmdYFPMsKoidEzYyGjQkG/GMl4F7yoB4BidEFO hiyama@lala";
  };

services.netbird = {
    useRoutingFeatures = "both";
    package = inputs.unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.netbird;
    clients = {
      sidonia = {
        port = 51815;
        login = {
          enable = true;
          setupKeyFile = "${pkgs.writeText "one-time-key" "344166FF-3BE1-4E05-AD2A-1247DFBB2038"}";
        };
        environment = {
          NB_MANAGEMENT_URL = "https://netbird.moppu.dev";
          NB_ADMIN_URL = "https://netbird.moppu.dev";
        };
        openFirewall = true;
        openInternalFirewall = true;
      };
    };
  };
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/hiyama/.config/sops/age/keys.txt";
  };
}
