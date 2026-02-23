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
    networking.hostName = "yure";
    nix.settings.max-jobs = 1; # set to 0 to use remote builder only
    catppuccin = {
        enable = true;
        flavor = "mocha";
        accent = "green";
    };
    sidonia = {
        userName = "shinatose";
        stateVer = "24.05";
        ssh.pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICw5RRyu1jEMpS5ekIfbdaHtWU/IyZ62LhfqK8xUIjGY shinatose@yure";
        services.distributedBuilds.client.enable = true;
        graphics.legacyGpu = true;
        desktop = {
            enable = true;
            compositor = "hyprland";
            monitors = [
                {
                    name = "LVDS-1";
                    scale = 1.0;
                }
            ];
        };
        geolocation.enable = true;
        text.comicCode.enable = false;
        input = {
            sensitivity = -0.1;
            keyLayout = "gb";
        };
        isLaptop = true;
    };
}
