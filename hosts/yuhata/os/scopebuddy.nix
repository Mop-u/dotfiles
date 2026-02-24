{
    config,
    pkgs,
    inputs,
    lib,
    ...
}:
{
    home-manager.users.${config.sidonia.userName}.wayland.windowManager.hyprland.settings.windowrule = [
        "match:initial_class gamescope, content game, tag +game"
    ];
    sidonia.desktop.environment.steam = {
        PROTON_ENABLE_NVAPI = 1;
        PROTON_ENABLE_WAYLAND = null;
        PROTON_ENABLE_HDR = null;
        ENABLE_HDR_WSI = null;
        WINE_CPU_TOPOLOGY = "8:0,1,2,3,4,5,6,7";
        # https://github.com/NixOS/nixpkgs/issues/162562#issuecomment-1523177264
        SDL_VIDEODRIVER = null;
        SCB_GAMESCOPE_ARGS = "-f -w 5120 -h 2160 -W 5120 -H 2160 -r 75 --hdr-enabled";
    };

    programs.steam = {
        # https://github.com/NixOS/nixpkgs/issues/162562#issuecomment-1523177264
        extraPackages = with pkgs; [
            libxcursor
            libxi
            libxinerama
            libxscrnsaver
            libpng
            libpulseaudio
            libvorbis
            stdenv.cc.cc.lib
            libkrb5
            keyutils
            gamescope
            scopebuddy
            wlr-randr
            jq
        ];
    };
}
