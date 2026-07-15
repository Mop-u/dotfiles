{ pkgs, modulesPath, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./lustrate.nix
  ];
  nix.settings.experimental-features = "flakes nix-command";

  # Hardware
  fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
  boot.loader.grub.device = "/dev/sda";
  boot.loader.timeout = 30;
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" ];
  boot.initrd.kernelModules = [ "nvme" ];
  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  

  # Networking
  networking = {
    useNetworkd = true;
    usePredictableInterfaceNames = true;
    hostName = "lala";
  };
  systemd.network = {
    enable = true;
    networks."40-wan" = {
      matchConfig.Name = "enxfa163ef42698";
      address = [ "2a0b:b600:3c05:3::1b6/128" "45.87.251.224/26" ];
      routes = [  { Gateway = "45.87.251.193"; GatewayOnLink = true; } ];
      dns = [ "2620:fe::10" "9.9.9.10" ];
    };
  };

  # Setup
  # boot.initrd.systemd.lustrate.enable = true; # From ./lustrate.nix
  # systemd.services.setup = rec {
  #   wantedBy = [ "basic.target" ];
  #   after = wantedBy;
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ConditionPathExists = "/etc/nixos/setup.sh";
  #     ExecStart = "/etc/nixos/setup.sh";
  #     ExecStartPost = "${pkgs.coreutils}/bin/rm /etc/nixos/setup.sh";
  #   };
  # };
}
