{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.sidonia;
in
lib.mkIf (cfg.desktop.enable) {

  security = {
    pam.services.login.enableGnomeKeyring = lib.mkDefault true;
    polkit.enable = lib.mkDefault true;
  };

  catppuccin.cursors.enable = lib.mkDefault config.catppuccin.enable;

  programs.dconf.enable = lib.mkDefault true;

  # https://nix-community.github.io/home-manager/options.xhtml#opt-xdg.portal.enable
  environment.pathsToLink = [
    "/share/xdg-desktop-portal"
    "/share/applications"
  ];

  services = {
    logind.settings.Login = {
      HandleLidSwitch = lib.mkDefault "suspend-then-hibernate";
      HandleLidSwitchExternalPower = lib.mkDefault "ignore";
      HandleLidSwitchDocked = lib.mkDefault "ignore";
    };
    gvfs.enable = lib.mkDefault true; # Mount, trash, and other functionalities
    tumbler.enable = lib.mkDefault true; # Thumbnail support for images
  };

  programs = {
    seahorse.enable = lib.mkDefault true;
    xfconf.enable = lib.mkDefault true;
  };

  # For ddcutil
  hardware.i2c.enable = lib.mkDefault true;
  environment.systemPackages = [ pkgs.ddcutil ];

  # https://gitlab.com/mission-center-devs/mission-center/-/wikis/Home/CPU
  services.udev.extraRules = ''
    SUBSYSTEM=="powercap", KERNEL=="intel-rapl*", \
        RUN+="${pkgs.coreutils}/bin/chgrp -R wheel /sys/%p/'", \
        RUN+="${pkgs.coreutils}/bin/chmod -R g+r /sys/%p/"
  '';

  security.wrappers.nethogs = {
    enable = lib.mkDefault true;
    owner = "root";
    group = "root";
    source = lib.getExe pkgs.nethogs;
    capabilities = lib.concatStringsSep "," [
      "cap_net_admin"
      "cap_net_raw"
      "cap_dac_read_search"
      "cap_sys_ptrace+pe"
    ];
  };

}
