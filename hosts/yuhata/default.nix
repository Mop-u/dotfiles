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
    ];

    home-manager.users.${config.sidonia.userName}.imports = [ ./home.nix ];

    networking.hostName = "yuhata";
    sidonia = {
        userName = "midorikawa";
        stateVer = "25.05";
        style.catppuccin = {
            flavor = "macchiato";
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
            environment = {
                steam = {
                    PROTON_ENABLE_NVAPI = 1;
                    PROTON_ENABLE_WAYLAND = null;
                    PROTON_ENABLE_HDR = null;
                    ENABLE_HDR_WSI = null;
                    WINE_CPU_TOPOLOGY = "8:0,1,2,3,4,5,6,7";
                };
            };
            monitors = [
                {
                    name = "desc:Lenovo Group Limited P40w-20 V9095052";
                    resolution.x = 5120;
                    resolution.y = 2160;
                    resolution.hz = 74.97900;
                    scale = 1.066667;
                    position = "0x0";
                    bitdepth = 10;
                    hdr = false;
                    #extraArgs = {
                    #    sdrbrightness = "1.3";
                    #    sdrsaturation = "1.0";
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

    programs = {
        sleepy-launcher.enable = true;
        coolercontrol.enable = true;
        steam.remotePlay.openFirewall = true;
    };
    hardware.keyboard.qmk.enable = true;
    services.udev.packages = [
        pkgs.via
        pkgs.huion-switcher
    ];
    boot.kernelModules = [ "digimend" ]; # for huion 540 tablet
    # Nvidia HDR support
    environment.systemPackages = [ pkgs.vulkan-hdr-layer-kwin6 ];

    sops = {
        defaultSopsFile = ../../secrets/secrets.yaml;
        defaultSopsFormat = "yaml";
        age.keyFile = "/home/midorikawa/.config/sops/age/keys.txt";
    };
}
