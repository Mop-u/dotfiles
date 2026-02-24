{
    config,
    pkgs,
    inputs,
    lib,
    ...
}:
{
    users.users.midorikawa.extraGroups = [ "gamemode" ];
    nixpkgs.overlays = [
        (final: prev: {
            gamemode = prev.gamemode.overrideAttrs (
                finalAttrs: prevAttrs: {
                    src = final.fetchFromGitHub {
                        owner = "FeralInteractive";
                        repo = "gamemode";
                        rev = "f0a569a5199974751a4a75ebdc41c8f0b8e4c909";
                        hash = "sha256-9DB8iWiyrM4EJ94ERC5SE9acrhqeI00BF1wU0umeNFg=";
                    };
                }
            );
        })
    ];
    programs.gamemode = {
        enable = true;
        enableRenice = true;
        settings = {
            # man gamemoded(8)
            general = {
                renice = 10;
            };
            gpu = {
                apply_gpu_optimisations = "accept-responsibility";
                gpu_device = 1;
                nv_per_profile_editable = 0; # https://github.com/FeralInteractive/gamemode/pull/547
                #nv_powermizer_mode = 1;
                #nv_core_clock_mhz_offset = 0;
                #nv_mem_clock_mhz_offset = 0;
            };
        };
    };
}
