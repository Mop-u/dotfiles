{
    config,
    lib,
    pkgs,
    inputs,
    ...
}:

{
    hardware.enableRedistributableFirmware = true;
    boot.loader = {
        efi.canTouchEfiVariables = true;
        systemd-boot = {
            enable = true;
            windows."11".efiDeviceHandle = "HD0b";
            edk2-uefi-shell.enable = true;
            memtest86.enable = true;
            configurationLimit = 20;
        };
        grub = {
            enable = false;
            devices = [ "nodev" ];
            efiSupport = true;
            useOSProber = true;
            configurationLimit = 20;
        };
    };

    boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
    ];
    boot.initrd.kernelModules = [ ];

    nix.settings.substituters = [ "https://attic.xuyh0120.win/lantian" ];
    nix.settings.trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
    boot.kernelPackages =
        inputs.cachyos.legacyPackages.x86_64-linux.linuxPackages-cachyos-latest-lto-x86_64-v3;

    boot.kernelModules = [
        "kvm-amd"
        "ntsync"
        "nvidia"
        "nvidia_modeset"
        "nvidia_uvm"
        "nvidia_drm"
    ];
    boot.extraModulePackages = [ ];

    fileSystems."/" = {
        device = "/dev/disk/by-uuid/26c580c5-ca8b-4df5-a631-54fb68cd61f4";
        fsType = "ext4";
    };

    fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/EBE7-D290";
        fsType = "vfat";
        options = [
            "fmask=0077"
            "dmask=0077"
        ];
    };

    swapDevices = [
        { device = "/dev/disk/by-uuid/4ccd9516-6157-4bcc-a49f-6298e6ec70d4"; }
    ];

    services.xserver.videoDrivers = [ "nvidia" ];
    nixpkgs.overlays = [ inputs.nvidia-patch.overlays.default ];
    hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = false;
        powerManagement.finegrained = false;
        open = true;
        nvidiaSettings = true;
        package =
            let
                patch = with pkgs.nvidia-patch; driver: (patch-nvenc (patch-fbc driver));
                unstable = import inputs.unstable {
                    inherit (pkgs.stdenv.hostPlatform) system;
                    config.allowUnfree = true;
                };
                kernelPackages = unstable.linuxKernel.packagesFor config.boot.kernelPackages.kernel;
            in
            kernelPackages.nvidiaPackages.beta; # latest/beta/production/stable
    };

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;

    nix.settings.system-features = [ "gccarch-znver3" ];
    nixpkgs.hostPlatform = {
        #gcc.arch = "znver3";
        #gcc.tune = "znver3";
        system = "x86_64-linux";
    };
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
