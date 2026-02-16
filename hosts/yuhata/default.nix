{
    config,
    pkgs,
    inputs,
    lib,
    ...
}:
{
    imports = [
        ./hardware-configuration.nix
        ./networkMounts.nix
        ./wayvr.nix
        ./scopebuddy.nix
    ];

    home-manager.users.${config.sidonia.userName}.imports = [ ./home.nix ];

    hardware.bluetooth = {
        powerOnBoot = true;
        settings = {
            General = {
                Experimental = true;
                FastConnectable = true;
            };
        };
    };
    networking.hostName = "yuhata";
    sidonia = {
        userName = "midorikawa";
        stateVer = "25.05";
        style.catppuccin = {
            flavor = "mocha";
            accent = "lavender";
        };
        ssh.pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJDCi7RR4mckEAgC7mVNFHNvzTg3JwvcKYrYKXqf1Hew midorikawa@yuhata";
        services = {
            distributedBuilds.client.enable = false;
            vr.enable = true;
        };
        geolocation.enable = true;
        desktop = {
            enable = true;
            compositor = "hyprland";
            monitors = [
                {
                    name = "desc:Lenovo Group Limited P40w-20 V9095052";
                    resolution.x = 5120;
                    resolution.y = 2160;
                    resolution.hz = 74.97900;
                    scale = 1.066667;
                    position = "0x0";
                    bitdepth = 10;
                    #extraArgs = {
                    #    cm = "hdredid";
                    #    sdrbrightness = "1.20";
                    #    sdr_min_luminance = "0.005";
                    #};
                }
                {
                    name = "desc:BNQ ZOWIE XL LCD JAG03521SL0";
                    resolution.x = 1920;
                    resolution.y = 1080;
                    resolution.hz = 60;
                    scale = 1.0; # 0.833333;
                    position = "4800x400";
                }
                {
                    name = "desc:Samsung Electric Company Q90A";
                    resolution.x = 3840;
                    resolution.y = 2160;
                    resolution.hz = 120;
                    scale = 1.5;
                    bitdepth = 10;
                    #hdr = true;
                }
            ];
        };
        text.comicCode.enable = true;
        tweaks = {
            audio = {
                behringerFix.enable = true;
                lowLatency = {
                    enable = true;
                    quantum = 128;
                    rate = 48000;
                };
            };
        };
    };

    services.hardware.openrgb.enable = true;
    nixpkgs.config.permittedInsecurePackages = [
        pkgs.mbedtls_2.name # for openrgb service
        pkgs.openssl_1_1.name # for openrgb service
    ];

    users.users.midorikawa.extraGroups = [ "gamemode" ];
    programs.gamemode = {
        enable = true;
        enableRenice = true;
        settings = {
            # man gamemoded(8)
            general = {
                renice = 10;
            };
            gpu = {
                apply_gpu_optimisations = "accept-responsibility";
                gpu_device = 1;
                nv_powermizer_mode = 1;
                #nv_mem_clock_mhz_offset = 0;
            };
        };
    };
    programs = {
        sleepy-launcher.enable = true;
        coolercontrol.enable = true;
        steam.remotePlay.openFirewall = true;
        gamescope.enable = true;
    };
    hardware.keyboard.qmk.enable = true;
    services.udev.packages = [
        pkgs.via
        pkgs.huion-switcher
    ];
    boot.kernelModules = [ "digimend" ]; # for huion 540 tablet
    # Nvidia HDR support
    environment.systemPackages = [
        pkgs.vulkan-hdr-layer-kwin6
    ];

    sops = {
        defaultSopsFile = ../../secrets/secrets.yaml;
        defaultSopsFormat = "yaml";
        age.keyFile = "/home/midorikawa/.config/sops/age/keys.txt";
    };
}
