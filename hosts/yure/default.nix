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
    ];
    sidonia = {
        userName = "shinatose";
        stateVer = "24.05";
        ssh.pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICw5RRyu1jEMpS5ekIfbdaHtWU/IyZ62LhfqK8xUIjGY shinatose@yure";
        services.audio.enable = true;
        services.kmscon.enable = true;
        services.distributedBuilds.client.enable = true;
        graphics = {
            enable = true;
            legacyGpu = true;
        };
        geolocation.enable = true;
        text.smallTermFont = false;
        style.catppuccin.flavor = "mocha";
        style.catppuccin.accent = "mauve";
        text.comicCode.enable = true;
        input.sensitivity = -0.1;
        input.keyLayout = "gb";
        isLaptop = true;
        programs.hyprland.monitors = [
            { 
                name = "LVDS-1";
                scale = 1.0;
            }
        ];
    };
}
