{
    config,
    pkgs,
    inputs,
    lib,
    ...
}:
{
    imports = [ ./os ];
    home-manager.users.${config.sidonia.userName}.imports = [ ./home ];
}
