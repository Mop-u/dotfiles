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
        hostName = "kaoru";
        userName = "hazama";
        stateVer = "23.11";
        style.catppuccin.flavor = "macchiato";
        style.catppuccin.accent = "mauve";
        text.comicCode.enable = true;
        services.goxlr.enable = false;
        isLaptop = true;
        graphics.enable = true;
        tweaks.withBehringerAudioInterface = true;
        programs.hyprland.monitors = [
            {
                name = "eDP-1";
                resolution = "2560x1600";
                refresh = 165.00400;
                scale = 1.333333;
                position = "6720x0";
                extraArgs = "bitdepth,10";
            }
            {
                name = "desc:Lenovo Group Limited P40w-20";
                resolution = "5120x2160";
                refresh = 74.97900;
                scale = 1.066667;
                position = "0x0";
            }
            {
                name = "desc:BNQ ZOWIE XL LCD JAG03521SL0";
                resolution = "1920x1080";
                refresh = 60.00;
                scale = 0.833333;
                position = "4800x400";
            }
        ];
    };
}
