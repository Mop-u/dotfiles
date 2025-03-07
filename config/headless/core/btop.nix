{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
{
    home-manager.users.${config.sidonia.userName} = {
        catppuccin.btop.enable = true;
        programs.btop = {
            enable = true;
        };
    };
}
