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
            vr.enable = false;
        };
        programs.hyprland.enable = true;
        geolocation.enable = true;
        graphics.enable = true;
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
        desktop.monitors = [
            {
                name = "desc:Lenovo Group Limited P40w-20 V9095052";
                resolution = "5120x2160";
                refresh = 74.97900;
                scale = 1.066667;
                position = "0x0";
                bitdepth = 10;
                hdr = true;
                extraArgs = "sdrbrightness,1.2";
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
                hdr = true;
            }
        ];
    };

    services = {
        desktopManager.cosmic = {
            enable = false;
            xwayland.enable = true;
        };
        hardware.openrgb.enable = true;
        sunshine = {
            enable = false;
            capSysAdmin = true;
            openFirewall = true;
        };

    };

    programs = {
        sleepy-launcher.enable = true;
        coolercontrol.enable = true;
        steam.remotePlay.openFirewall = true;
    };


    # https://github.com/nix-community/nixpkgs-xr/issues/468#issuecomment-3212479060
    #services.monado.package = pkgs.monado.overrideAttrs (oldAttrs: {
    #    cmakeFlags = oldAttrs.cmakeFlags ++ [
    #        (lib.cmakeBool "XRT_HAVE_OPENCV" false)
    #    ];
    #});
    #programs.steam.gamescopeSession.env = {
    #    "SDL_VIDEODRIVER" = "x11";
    #};

    home-manager.users.${config.sidonia.userName} = {
        home.packages = [
            pkgs.bs-manager
        ];
        #wayland.windowManager.hyprland.settings.env = [
        #    "ENABLE_HDR_WSI,1"
        #    "PROTON_ENABLE_HDR,1"
        #    "PROTON_ENABLE_WAYLAND,1"
        #];
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
