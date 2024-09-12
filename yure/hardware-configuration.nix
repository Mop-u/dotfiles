{ inputs, config, lib, pkgs, modulesPath, ... }:
let
    keyFile = "/boot/crypto_keyfile.bin";
in {
    imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot.loader.grub = {
        enable = true;
        device = "/dev/sda";
        useOSProber = true;
        enableCryptodisk = true;
    };

    boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ata_piix" "ahci" "firewire_ohci" "usb_storage" "sd_mod" "sdhci_pci" ];
    boot.initrd.kernelModules = [ ];
    #boot.kernelPackages = pkgs.linuxPackages_zen;
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    fileSystems."/" = {
        device = "/dev/disk/by-uuid/6be0b367-cd67-468c-8792-4e53dc357244";
        fsType = "ext4";
    };

    swapDevices = [
        { device = "/dev/disk/by-uuid/a3d42fd4-40f7-4d88-a932-fa0439a96f70"; }
    ];

    boot.initrd.secrets = {
        "${keyFile}" = null;
    };

    boot.initrd.luks.devices."luks-27cc08a3-261e-4da1-beae-1fe9a61f57ef" = {
        allowDiscards = true;
        keyFile = keyFile;
        device = "/dev/disk/by-uuid/27cc08a3-261e-4da1-beae-1fe9a61f57ef";
    };

    boot.initrd.luks.devices."luks-6f53bc66-23d8-4c65-aeb0-ce8775b1552c" = {
        allowDiscards = true;
        keyFile = keyFile;
        device = "/dev/disk/by-uuid/6f53bc66-23d8-4c65-aeb0-ce8775b1552c";
    };

    hardware.display = {
        outputs."LVDS-1".edid = "1400x1050_60hz.bin";
        edid.enable = true;
        edid.packages = [(pkgs.runCommand "edid-1400x1050-60hz" {} ''
            mkdir -p "$out/lib/firmware/edid"
            base64 -d > "$out/lib/firmware/edid/1400x1050_60hz.bin" <<'EOF'
            AP///////wA15jcTAgAAABcZAQOAGRJ4469AlVZKjyUgUFQhCACQQAEAAQABAAEBAQEBAQEBwCd4yFAaCkAUdCUA9bgAAAAYAAAAEAAAAAAAAAAAAAAAAAAAAAAADwCQQzwAAAATAgAJ5QAAAAAA/gBIVjEyMVAwMS0xMDAKAJ4=
            EOF
        '')];
    };

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.enp0s25.useDHCP = lib.mkDefault true;
    # networking.interfaces.wls3.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    services.thermald.enable = true; # intel thermal protection
    services.tlp = {
        enable = true; # laptop power saving etc
        settings = {
            PLATFORM_PROFILE_ON_AC = "performance";
            PLATFORM_PROFILE_ON_BAT = "low-power";
            CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
            CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
            CPU_SCALING_GOVERNOR_ON_AC = "performance";
            CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
            CPU_BOOST_ON_AC = 1;
            CPU_BOOST_ON_BAT = 0;

            START_CHARGE_THRESH_BAT0 = 40;
            STOP_CHARGE_THRESH_BAT0 = 80;
            NATACPI_ENABLE = 1; # battery care driver
        };
    };
}
