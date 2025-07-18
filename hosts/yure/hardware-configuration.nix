{
    inputs,
    config,
    lib,
    pkgs,
    ...
}:
{

    hardware.enableRedistributableFirmware = true;

    # This is a dual core system :)
    nix.settings.cores = 1;

    boot.loader.grub = {
        enable = true;
        device = "/dev/sda";
        useOSProber = true;
        gfxmodeBios = "1280x1024,auto";
        gfxpayloadBios = "keep";
        configurationLimit = 10;
    };

    boot.initrd.availableKernelModules = [
        "uhci_hcd"
        "ehci_pci"
        "ata_piix"
        "ahci"
        "firewire_ohci"
        "usb_storage"
        "sd_mod"
        "sdhci_pci"
    ];
    boot.initrd.kernelModules = [ ];
    #boot.kernelPackages = pkgs.linuxPackages_zen;
    boot.kernelPackages = pkgs.linuxPackages_6_12;
    boot.kernelModules = [
        "kvm-intel"
        "tp_smapi"
    ];
    boot.extraModulePackages = [ ];

    fileSystems."/" = {
        device = "/dev/disk/by-uuid/6be0b367-cd67-468c-8792-4e53dc357244";
        fsType = "ext4";
    };

    swapDevices = [ { device = "/dev/disk/by-uuid/a55aed88-5155-4c6a-8508-34360cd1212a"; } ];
    boot.resumeDevice = "/dev/disk/by-uuid/a55aed88-5155-4c6a-8508-34360cd1212a";

    hardware.display = {
        outputs."LVDS-1".edid = "1400x1050_60hz.bin";
        edid.enable = true;
        edid.packages = [
            (pkgs.runCommand "edid-1400x1050-60hz" { } ''
                mkdir -p "$out/lib/firmware/edid"
                base64 -d > "$out/lib/firmware/edid/1400x1050_60hz.bin" <<'EOF'
                AP///////wA15jcTAgAAABcZAQOAGRJ4469AlVZKjyUgUFQhCACQQAEAAQABAAEBAQEBAQEBwCd4yFAaCkAUdCUA9bgAAAAYAAAAEAAAAAAAAAAAAAAAAAAAAAAADwCQQzwAAAATAgAJ5QAAAAAA/gBIVjEyMVAwMS0xMDAKAJ4=
                EOF
            '')
        ];
    };

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.enp0s25.useDHCP = lib.mkDefault true;
    # networking.interfaces.wls3.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    nixpkgs.system = "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    environment.systemPackages = with pkgs; [
        intel-gpu-tools
    ];

    powerManagement.enable = true;
    services.thermald.enable = true; # intel thermal protection
    services.tlp = {
        enable = true; # laptop power saving etc
        settings = {
            PLATFORM_PROFILE_ON_AC = "performance";
            PLATFORM_PROFILE_ON_BAT = "low-power";
            CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
            CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
            CPU_SCALING_GOVERNOR_ON_AC = "performance";
            CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";

            # Limit max freq to avoid crashing under load on low battery
            CPU_SCALING_MAX_FREQ_ON_BAT = 1200000;

            START_CHARGE_THRESH_BAT0 = 40;
            STOP_CHARGE_THRESH_BAT0 = 80;
            NATACPI_ENABLE = 1; # battery care driver
        };
    };
    services.thinkfan = {
        enable = true;
        levels = [
            [
                0
                0
                55
            ]
            [
                1
                40
                50
            ]
            [
                2
                45
                55
            ]
            [
                3
                50
                60
            ]
            [
                6
                55
                65
            ]
            [
                7
                60
                75
            ]
            [
                "level full-speed"
                70
                85
            ]
            [
                "level disengaged"
                80
                32767
            ]
        ];
    };
}
