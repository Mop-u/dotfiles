{
    config,
    lib,
    pkgs,
    inputs,
    ...
}:

{

    boot.initrd.availableKernelModules = [
        "xhci_pci"
        "ehci_pci"
        "ahci"
        "usb_storage"
        "sd_mod"
        "sr_mod"
    ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];

    nix.settings.substituters = [ "https://attic.xuyh0120.win/lantian" ];
    nix.settings.trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
    boot.kernelPackages =
        inputs.cachyos.legacyPackages.x86_64-linux.linuxPackages-cachyos-latest-lto-x86_64-v3;

    boot.extraModulePackages = [ ];

    fileSystems."/" = {
        device = "/dev/disk/by-uuid/c861c0fc-67f0-4f88-9ef2-d60ac7343ddf";
        fsType = "ext4";
    };

    swapDevices = [
        { device = "/dev/disk/by-uuid/189dd6aa-0066-4bc8-8598-534666eba59e"; }
    ];

    networking.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
