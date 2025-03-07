{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
let
    cfg = config.sidonia;
in
{
    options.sidonia.services.goxlr.enable =
        with lib;
        mkOption {
            description = "Enable GoXLR support";
            type = types.bool;
            default = false;
        };
    config = lib.mkIf (cfg.services.goxlr.enable) {
        services.goxlr-utility.enable = true;
        services.goxlr-utility.autoStart.xdg = false; # respect goxlr-utility's autostart toggle
        home-manager.users.${config.sidonia.userName} = {
            home.packages = [
                #inputs.goxlr-utility-ui.packages.${pkgs.system}.goxlr-utility-ui
                pkgs.goxlr-utility
            ];
            #wayland.windowManager.hyprland.settings.windowrulev2 = [
            #    "float, class:(goxlr-utility-ui), title:(GoXLR Utility)"
            #];
        };
    };
}
