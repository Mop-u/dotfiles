{ inputs, config, pkgs, lib, target, ... }:
{
    services.plex = {
        enable = true;
        openFirewall = true;
        extraScanners = [];
        extraPlugins = [];
    };
}