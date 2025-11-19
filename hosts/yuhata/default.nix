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
            distributedBuilds.client.enable = true;
            vr.enable = true;
        };
        geolocation.enable = true;
        graphics.enable = true;
        text.comicCode.enable = true;
        tweaks.withBehringerAudioInterface = true;
        desktop.monitors = [
            {
                name = "desc:Lenovo Group Limited P40w-20 V9095052";
                resolution = "5120x2160";
                refresh = 74.97900;
                scale = 1.066667;
                position = "0x0";
            }
            {
                name = "desc:BNQ ZOWIE XL LCD JAG03521SL0";
                resolution = "1920x1080";
                refresh = 60.00;
                scale = 1.0; # 0.833333;
                position = "4800x400";
            }
        ];
    };

    sops = {
        defaultSopsFile = ../../secrets/secrets.yaml;
        defaultSopsFormat = "yaml";
        age.keyFile = "/home/midorikawa/.config/sops/age/keys.txt";
    };

    programs = {
        sleepy-launcher.enable = true;
        coolercontrol.enable = true;
    };

    # https://github.com/nix-community/nixpkgs-xr/issues/468#issuecomment-3212479060
    services.monado.package = pkgs.monado.overrideAttrs (oldAttrs: {
        cmakeFlags = oldAttrs.cmakeFlags ++ [
            (lib.cmakeBool "XRT_HAVE_OPENCV" false)
        ];
    });

    home-manager.users.${config.sidonia.userName} = {
        home.packages = [
            pkgs.bs-manager
        ];
    };
    services.hardware.openrgb.enable = true;
    nixpkgs.config.permittedInsecurePackages =
        if config.services.hardware.openrgb.enable then
            [
                "mbedtls-2.28.10"
                "openssl-1.1.1w"
            ]
        else
            [ ];
}
