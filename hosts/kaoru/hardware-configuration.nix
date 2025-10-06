{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
let
    intelGPU = "46a6";
in
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
    boot.initrd.kernelModules = [ ];
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.kernelModules = [
        "kvm-intel"
        #"r8152" # realtek USB 2.5Gbe
        "r8125" # realtek PCIe 2.5Gbe
        "snd_usb_audio"
    ];
    boot.extraModulePackages = with config.boot.kernelPackages; [ ];
    #boot.kernelParams = [
    #    "i915.force_probe=!${intelGPU}"
    #    "xe.force_probe=${intelGPU}"
    #];

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

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    nixpkgs.system = "x86_64-linux";
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
    hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = false;
        powerManagement.finegrained = false;
        open = true;
        nvidiaSettings = true;
        #package = config.boot.kernelPackages.nvidiaPackages.latest; # latest/beta/production/stable
        package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
            # https://github.com/NixOS/nixpkgs/blob/master/pkgs/os-specific/linux/nvidia-x11/default.nix
            version = "580.95.05";
            sha256_64bit = "sha256-hJ7w746EK5gGss3p8RwTA9VPGpp2lGfk5dlhsv4Rgqc=";
            sha256_aarch64 = "sha256-zLRCbpiik2fGDa+d80wqV3ZV1U1b4lRjzNQJsLLlICk=";
            openSha256 = "sha256-RFwDGQOi9jVngVONCOB5m/IYKZIeGEle7h0+0yGnBEI=";
            settingsSha256 = "sha256-F2wmUEaRrpR1Vz0TQSwVK4Fv13f3J9NJLtBe4UP2f14=";
            usePersistenced = false;
        };
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
    services.tlp = {
        enable = true; # laptop power saving etc
        settings = {
            PLATFORM_PROFILE_ON_AC = "balanced";
            PLATFORM_PROFILE_ON_BAT = "quiet";
            CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";
            CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
            CPU_SCALING_GOVERNOR_ON_AC = "powersave";
            CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
            CPU_BOOST_ON_AC = 0;
            CPU_HWP_DYN_BOOST_ON_AC = 0;
            CPU_BOOST_ON_BAT = 0;
            CPU_HWP_DYN_BOOST_ON_BAT = 0;
            RUNTIME_PM_ON_AC = "auto";
            RUNTIME_PM_ON_BAT = "auto";
            #CPU_MAX_PERF_ON_AC = 80;

            USB_AUTOSUSPEND = 0; # Fix for behringer audio interface connected to TB4 dock

            START_CHARGE_THRESH_BAT0 = 40;
            STOP_CHARGE_THRESH_BAT0 = 80;
            NATACPI_ENABLE = 1; # battery care driver
        };
    };
}
