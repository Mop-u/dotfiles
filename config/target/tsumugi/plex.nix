{ inputs, config, pkgs, lib, target, ... }:
{
    services.plex = {
        enable = true;
        openFirewall = true;
        extraScanners = [
            inputs.plexASS
        ];
        extraPlugins = [
            inputs.plexHama
        ];
    };
    services.sonarr = {
        enable = true;
        openFirewall = true;
    };
    services.radarr = {
        enable = true;
        openFirewall = true;
    };
}