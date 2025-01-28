{inputs, config, pkgs, lib, target, ... }:
{
    services.goxlr-utility.enable = true;
    services.goxlr-utility.autoStart.xdg = false; # respect goxlr-utility's autostart toggle
    home-manager.users.${target.userName} = {
        home.packages = [
            #inputs.goxlr-utility-ui.packages.${pkgs.system}.goxlr-utility-ui
            pkgs.goxlr-utility
        ];
        #wayland.windowManager.hyprland.settings.windowrulev2 = [
        #    "float, class:(goxlr-utility-ui), title:(GoXLR Utility)"
        #];   
    };
}
