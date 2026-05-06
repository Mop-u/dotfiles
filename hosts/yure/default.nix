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
    system.stateVersion = "24.05";
    sidonia = {
        userName = "shinatose";
        ssh.pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICw5RRyu1jEMpS5ekIfbdaHtWU/IyZ62LhfqK8xUIjGY shinatose@yure";
        services.distributedBuilds.client.enable = true;
        graphics.legacyGpu = true;
        desktop = {
            enable = true;
            compositor = "niri";
            shell = "noctalia";
        };
        geolocation.enable = true;
        text.comicCode.enable = true;
        input.keyLayout = "uk";
        isLaptop = true;
    };
    home-manager.users.${config.sidonia.userName}.imports = [./home.nix];
}
