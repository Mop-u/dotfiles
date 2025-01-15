{inputs, config, pkgs, lib, target, ... }: let
    assets = "/home/${target.username}/.steam/steam/steamapps/common/wallpaper_engine/assets";
in {
    home-manager.users.${target.userName} = {
        home.packages = [
            pkgs.linux-wallpaperengine
        ];
    };
}