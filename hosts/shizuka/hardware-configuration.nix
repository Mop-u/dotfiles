{
    config,
    lib,
    pkgs,
    inputs,
    ...
}:

{
    # Bootloader.
    boot.loader.grub = {
        enable = true;
        device = "/dev/sda";
        useOSProber = true;
        gfxmodeBios = "1920x1080,auto";
        gfxpayloadBios = "keep";
        configurationLimit = 20;
    };

    boot.initrd.availableKernelModules = [
        "xhci_pci"
        "ehci_pci"
        "ahci"
        "usb_storage"
        "sd_mod"
        "sr_mod"
    ];
    boot.initrd.kernelModules = [ ];
    boot.blacklistedKernelModules = [
        #"ath3k"
        #"btusb"
    ];
    boot.kernelModules = [
        "kvm-intel"
        "ntsync"
    ];

    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3;
    boot.extraModulePackages = [ ];

    fileSystems."/" = {
        device = "/dev/disk/by-uuid/c861c0fc-67f0-4f88-9ef2-d60ac7343ddf";
        fsType = "ext4";
    };

    swapDevices = [
        { device = "/dev/disk/by-uuid/189dd6aa-0066-4bc8-8598-534666eba59e"; }
        {
            device = "/var/lib/swapfile";
            size = 16*1024; # 16 Gib
        }
    ];

    networking.useDHCP = lib.mkDefault true;

    hardware.graphics.extraPackages = [
        (pkgs.intel-vaapi-driver.override { enableHybridCodec = true; })
        pkgs.libva-vdpau-driver
    ];

    hardware.bluetooth = {
        powerOnBoot = true;
        settings = {
            General = {
                Experimental = true;
                FastConnectable = true;
            };
        };
    };

    nixpkgs.hostPlatform.system = "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
# echo 1 > /sys/bus/platform/drivers/ideapad_acpi/VPC2004\:00/fan_mode
