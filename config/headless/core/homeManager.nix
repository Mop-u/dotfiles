{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
{

    home-manager = {
        useGlobalPkgs = true;
        backupFileExtension = "backup";
    };

    home-manager.users.${config.sidonia.userName} = {

        home = {
            username = config.sidonia.userName;
            homeDirectory = "/home/${config.sidonia.userName}";
            stateVersion = config.sidonia.stateVer;
        };

        catppuccin = {
            enable = true;
            accent = config.sidonia.style.catppuccin.accent;
            flavor = config.sidonia.style.catppuccin.flavor;
        };
    };
}
