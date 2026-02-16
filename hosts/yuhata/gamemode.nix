{
    config,
    pkgs,
    inputs,
    lib,
    ...
}:
{
    users.users.midorikawa.extraGroups = [ "gamemode" ];
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
                #gpu_device = 1;
                nv_powermizer_mode = 1;
                #nv_mem_clock_mhz_offset = 0;
            };
        };
    };
}
