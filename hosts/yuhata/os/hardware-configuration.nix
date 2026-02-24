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
    hardware.nvidia =
        let
            patch =
                with pkgs.nvidia-patch;
                driver:
                let
                    base = patch-nvenc (patch-fbc driver);
                in
                base
                // {
                    open = base.open.overrideAttrs (oldAttrs: {
                        patches = (oldAttrs.patches or [ ]) ++ [
                            (pkgs.fetchpatch {
                                url = "https://raw.githubusercontent.com/CachyOS/CachyOS-PKGBUILDS/master/nvidia/nvidia-utils/kernel-6.19.patch";
                                sha256 = "sha256-YuJjSUXE6jYSuZySYGnWSNG5sfVei7vvxDcHx3K+IN4=";
                            })
                        ];
                    });
                };
        in
        {
            modesetting.enable = true;
            powerManagement.enable = false;
            powerManagement.finegrained = false;
            open = true;
            nvidiaSettings = true;
            #package = patch config.boot.kernelPackages.nvidiaPackages.latest; # latest/beta/production/stable
            package = patch (
                config.boot.kernelPackages.nvidiaPackages.mkDriver {
                    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/os-specific/linux/nvidia-x11/default.nix
                    version = "590.48.01";
                    sha256_64bit = "sha256-ueL4BpN4FDHMh/TNKRCeEz3Oy1ClDWto1LO/LWlr1ok=";
                    sha256_aarch64 = "sha256-FOz7f6pW1NGM2f74kbP6LbNijxKj5ZtZ08bm0aC+/YA=";
                    openSha256 = "sha256-hECHfguzwduEfPo5pCDjWE/MjtRDhINVr4b1awFdP44=";
                    settingsSha256 = "sha256-NWsqUciPa4f1ZX6f0By3yScz3pqKJV1ei9GvOF8qIEE=";
                    persistencedSha256 = "sha256-wsNeuw7IaY6Qc/i/AzT/4N82lPjkwfrhxidKWUtcwW8=";
                }
            );
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
