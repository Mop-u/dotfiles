{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [ ./hardware-configuration.nix ];
  home-manager.users.${config.sidonia.userName}.imports = [ ./home.nix ];
  networking.hostName = "yure";
  nix = {
    monitored.enable = true;
    settings.max-jobs = 1; # set to 0 to use remote builder only
  };
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "green";
  };
  system.stateVersion = "24.05";
  sidonia = {
    userName = "shinatose";
    ssh.pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICw5RRyu1jEMpS5ekIfbdaHtWU/IyZ62LhfqK8xUIjGY shinatose@yure";
    services.distributedBuilds.client.enable = true;
    graphics.legacyGpu = true;
    desktop.enable = true;
    geolocation.enable = true;
    text.comicCode.enable = true;
    isLaptop = true;
    netbird.oneTimeKey = "1F3C7497-74AE-4194-8DEF-C7E0D3ECBC8F";
  };
  services.xserver.xkb = {
    layout = "gb,us";
    model = "thinkpad60";
  };
}
