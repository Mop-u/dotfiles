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

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/hiyama/.config/sops/age/keys.txt";
  };
}
