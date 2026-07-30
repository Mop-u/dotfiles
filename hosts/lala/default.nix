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
    clients.wt0 = {
      port = 51821;
      login = {
        enable = true;
        setupKeyFile = "${pkgs.writeText "one-time-key" "4EA018E4-F27C-498E-9DAD-FB9E9D2E52C6"}";
      };
      openFirewall = true;
      openInternalFirewall = true;
    };
  };

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/hiyama/.config/sops/age/keys.txt";
  };
}
