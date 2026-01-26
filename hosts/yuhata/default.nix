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
        programs.hyprland.enable = true;
        geolocation.enable = true;
        desktop = {
            enable = true;
            compositor = "hyprland";
            environment = {
                steam = {
                    PROTON_ENABLE_NVAPI = 1;
                    PROTON_ENABLE_WAYLAND = null;
                    ENABLE_HDR_WSI = null;
                    PROTON_ENABLE_HDR = null;
                };
            };
            monitors = [
                {
                    name = "desc:Lenovo Group Limited P40w-20 V9095052";
                    resolution = "5120x2160";
                    refresh = 74.97900;
                    scale = 1.066667;
                    position = "0x0";
                    bitdepth = 10;
                    hdr = false;
                    #extraArgs = "sdrbrightness,1.2,sdrsaturation,1.1";
                }
                {
                    name = "desc:BNQ ZOWIE XL LCD JAG03521SL0";
                    resolution = "1920x1080";
                    refresh = 60.00;
                    scale = 1.0; # 0.833333;
                    position = "4800x400";
                }
                {
                    name = "desc:Samsung Electric Company Q90A";
                    resolution = "3840x2160";
                    refresh = 120.00;
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

    services = {
        hardware.openrgb.enable = true;
    };

    programs = {
        sleepy-launcher.enable = true;
        coolercontrol.enable = true;
        steam.remotePlay.openFirewall = true;
    };
    hardware.keyboard.qmk.enable = true;
    services.udev.packages = [ pkgs.via ];
    home-manager.users.${config.sidonia.userName} = {
        home.packages = [
            pkgs.bs-manager
            pkgs.via
            pkgs.qmk
        ];
    };
    # Nvidia HDR support
    environment.systemPackages = [ pkgs.vulkan-hdr-layer-kwin6 ];

    nixpkgs.config.permittedInsecurePackages =
        if config.services.hardware.openrgb.enable then
            [
                "mbedtls-2.28.10"
                "openssl-1.1.1w"
            ]
        else
            [ ];

    sops = {
        defaultSopsFile = ../../secrets/secrets.yaml;
        defaultSopsFormat = "yaml";
        age.keyFile = "/home/midorikawa/.config/sops/age/keys.txt";
    };
}
