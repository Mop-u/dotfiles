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
        PROTON_FSR4_UPGRADE = null;
        PROTON_DLSS_UPGRADE = null;
        PROTON_DXVK_GPLASYNC = 1;
        #WINE_USE_TAKE_FOCUS = 1;
        ENABLE_HDR_WSI = null;
        WINE_CPU_TOPOLOGY = "16:0,1,2,3,4,5,6,7,16,17,18,19,20,21,22,23";
        # https://github.com/NixOS/nixpkgs/issues/162562#issuecomment-1523177264
        SDL_VIDEODRIVER = null;
        SCB_GAMESCOPE_ARGS = "-f -w 5120 -h 2160 -W 5120 -H 2160 -r 75 --hdr-enabled"; # scopebuddy -w 3200 -h 1800 -W 5120 -H 2160 -F nis  -f -r 150 -e --sdr-gamut-wideness 1 -- env SteamDeck=1
    };

    programs.steam.extraPackages = with pkgs; [
        gamescope
        scopebuddy
        wlr-randr
        jq
    ];
}
