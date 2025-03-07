{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
{
    home-manager.users.${config.sidonia.userName} = {
        catppuccin.nvim.enable = true;
        programs.neovim = {
            enable = true;
            defaultEditor = true;
        };
    };
}
