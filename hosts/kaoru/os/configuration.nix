{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{

  networking.hostName = "kaoru";
  nix = {
    monitored.enable = true;
    settings = {
      keep-outputs = true;
      max-jobs = 4;
      cores = 8; # avoid thermal throttling
    };
  };
  services = {
    supergfxd.enable = true;
    asusd.enable = true;
  };
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "mauve";
  };

  system.stateVersion = "23.11";
  programs.kdeconnect.enable = true;
  programs.gpu-screen-recorder.enable = true;
  sidonia = {
    userName = "hazama";
    ssh.pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINfNV3Z/LI/4ItskdADIC4JWqfW3Wae4TRK/Ahos5TgB hazama@kaoru";
    text.comicCode.enable = true;
    services.distributedBuilds.client.enable = false;
    isLaptop = true;
    geolocation.enable = true;
    desktop.enable = true;
  };
  sops = {
    defaultSopsFile = ../../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/${config.sidonia.userName}/.config/sops/age/keys.txt";
  };
  services.netbird = {
    useRoutingFeatures = "client";
    clients = {
      sidonia = {
        port = 51820;
        login = {
          enable = true;
          setupKeyFile = "${pkgs.writeText "one-time-key" "7D99AE7C-B3D2-47F8-BE13-02BA9F66DB92"}";
        };
        environment = {
          NB_MANAGEMENT_URL = "https://netbird.moppu.dev";
          NB_ADMIN_URL = "https://netbird.moppu.dev";
        };
        openFirewall = true;
        openInternalFirewall = true;
      };
      wt0 = {
        port = 51821;
        login = {
          enable = true;
          setupKeyFile = "${pkgs.writeText "one-time-key" "0C185300-F30B-4C4B-8B55-6383B615AA26"}";
        };
        openFirewall = true;
        openInternalFirewall = true;
      };
    };
  };
}
