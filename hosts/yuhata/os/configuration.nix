{
    config,
    pkgs,
    inputs,
    lib,
    ...
}:
{
    hardware.bluetooth = {
        powerOnBoot = true;
        settings = {
            General = {
                Experimental = true;
                FastConnectable = true;
            };
        };
    };
    catppuccin = {
        enable = true;
        flavor = "mocha";
        accent = "lavender";
    };
    networking.hostName = "yuhata";
    system.stateVersion = "25.05";
    sidonia = {
        userName = "midorikawa";
        ssh.pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJDCi7RR4mckEAgC7mVNFHNvzTg3JwvcKYrYKXqf1Hew midorikawa@yuhata";
        services = {
            distributedBuilds.client.enable = false;
            vr.enable = false;
        };
        geolocation.enable = true;
        desktop = {
            enable = true;
            compositor = "niri";
            shell = "noctalia";
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
        gamescope.enable = true;
        kdeconnect.enable = true;
    };
    hardware.keyboard.qmk.enable = true;
    services.udev.packages = [
        pkgs.via
        pkgs.huion-switcher
    ];
    boot.kernelModules = [ "digimend" ]; # for huion 540 tablet

}
