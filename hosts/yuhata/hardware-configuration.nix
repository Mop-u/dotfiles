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
    boot.kernelPackages = pkgs.linuxPackages_latest;
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
            patch = with pkgs.nvidia-patch; driver: patch-nvenc (patch-fbc driver);
        in
        {
            modesetting.enable = true;
            powerManagement.enable = false;
            powerManagement.finegrained = false;
            open = true;
            nvidiaSettings = true;
            #package = patch config.boot.kernelPackages.nvidiaPackages.latest; # latest/beta/production/stable
            package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
                # https://github.com/NixOS/nixpkgs/blob/master/pkgs/os-specific/linux/nvidia-x11/default.nix
                version = "590.44.01";
                sha256_64bit = "sha256-VbkVaKwElaazojfxkHnz/nN/5olk13ezkw/EQjhKPms=";
                sha256_aarch64 = "sha256-gpqz07aFx+lBBOGPMCkbl5X8KBMPwDqsS+knPHpL/5g=";
                openSha256 = "sha256-ft8FEnBotC9Bl+o4vQA1rWFuRe7gviD/j1B8t0MRL/o=";
                settingsSha256 = "sha256-wVf1hku1l5OACiBeIePUMeZTWDQ4ueNvIk6BsW/RmF4=";
                persistencedSha256 = "sha256-nHzD32EN77PG75hH9W8ArjKNY/7KY6kPKSAhxAWcuS4=";
            };
        };

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
