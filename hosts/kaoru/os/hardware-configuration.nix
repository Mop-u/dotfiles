{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
{

    hardware.enableRedistributableFirmware = true;

    boot.loader = {
        efi.canTouchEfiVariables = true;
        grub = {
            enable = true;
            devices = [ "nodev" ];
            efiSupport = true;
            useOSProber = true;
            configurationLimit = 20;
        };
    };

    boot.initrd.availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "thunderbolt_net"
        "vmd"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "sdhci_pci"
        "aesni_intel"
        "cryptd"
    ];
    boot.initrd.kernelModules = [
        "thunderbolt"
    ];

    nix.settings.substituters = [ "https://attic.xuyh0120.win/lantian" ];
    nix.settings.trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
    boot.kernelPackages =
        inputs.cachyos.legacyPackages.x86_64-linux.linuxPackages-cachyos-latest-lto-x86_64-v3;

    boot.kernelModules = [
        "kvm-intel"
        "r8125" # realtek PCIe 2.5Gbe
        "snd_usb_audio"
    ];
    boot.extraModulePackages = with config.boot.kernelPackages; [ ];

    fileSystems."/" = {
        device = "/dev/disk/by-uuid/75980f2d-cc48-4245-b6c5-31bf9d0465bc";
        fsType = "ext4";
    };

    fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/8F59-FE20";
        fsType = "vfat";
        options = [
            "fmask=0022"
            "dmask=0022"
        ];
    };

    swapDevices = [
        { device = "/dev/disk/by-uuid/efa4d278-62f5-48ce-8fdd-6571fa61ea1a"; }
    ];

    boot.initrd.luks.devices."luksroot" = {
        allowDiscards = true;
        device = "/dev/disk/by-uuid/04f8ed32-deda-4e3d-a91b-e9e6470a0ac9";
    };

    boot.initrd.luks.devices."luksswap" = {
        allowDiscards = true;
        device = "/dev/disk/by-uuid/8d864adf-9a85-433f-8919-eb6a8371c077";
    };

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.eno2.useDHCP = lib.mkDefault true;
    # networking.interfaces.enp0s20f0u1u4.useDHCP = lib.mkDefault true;
    # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

    nix.settings.system-features = [ "gccarch-alderlake" ];
    nixpkgs.hostPlatform = {
        #gcc.arch = "alderlake";
        #gcc.tune = "alderlake";
        system = "x86_64-linux";
    };
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    environment.systemPackages = with pkgs; [
        nvtopPackages.full
        intel-gpu-tools
    ];
    hardware.graphics.extraPackages = with pkgs; [
        # modern intel
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        libvdpau-va-gl # VDPAU_DRIVER=va_gl
        #nvidia
        nvidia-vaapi-driver # LIBVA_DRIVER_NAME=nvidia # this doesn't seem to work with mixed intel/nvidia
        # VDPAU_DRIVER=nvidia
    ];

    services.hardware.bolt.enable = true;

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
            prime = {
                # Sync and Offload cannot be enabled at the same time!
                sync.enable = true;
                offload.enable = false;
                offload.enableOffloadCmd = false;
                reverseSync.enable = false;
                allowExternalGpu = false;
                intelBusId = "PCI:0:2:0";
                nvidiaBusId = "PCI:1:0:0";
            };
        };

    environment.sessionVariables = {

        #LIBVA_DRIVER_NAME = "iHD"; # default to intel hardware acceleration
        #VDPAU_DRIVER = "va_gl"; # intel vdpau fallback
        #__GL_GSYNC_ALLOWED = "1";
        #__GL_VRR_ALLOWED = "1";
        NVD_BACKEND = "direct"; # fixes nvidia VA-API hardware video acceleration

        # Force NVIDIA offload for all applications
        #__NV_PRIME_RENDER_OFFLOAD          = "1";
        #__NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA_G0";
        #__GLX_VENDOR_LIBRARY_NAME          = "nvidia";
        #__VK_LAYER_NV_optimus              = "NVIDIA_only";

        #AQ_DRM_DEVICES =
        #    let
        #        dGPU = "/dev/dri/card0";
        #        iGPU = "/dev/dri/card1";
        #    in
        #    builtins.concatStringsSep ":" [
        #        iGPU
        #        dGPU
        #    ];
    };

    powerManagement.enable = true;
    services.thermald.enable = true; # intel thermal protection
}
