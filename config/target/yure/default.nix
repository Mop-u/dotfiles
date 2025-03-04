{ config, pkgs, inputs, lib, ... }: {
    imports = [
        ./hardware-configuration.nix
    ];
    sidonia = {
        hostName = "yure";
        userName = "shinatose";
        stateVer = "24.05";
        graphics.enable = true;
        graphics.legacyGpu = true;
        text.smallTermFont = false;
        style.catppuccin.flavor = "mocha";
        style.catppuccin.accent = "mauve";
        text.comicCode.enable = true;
        input.sensitivity = -0.1;
        input.keyLayout = "gb";
        isLaptop = true;
        monitors = [{name="LVDS-1";}];
    };
}