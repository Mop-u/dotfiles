{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
{
    services.steam-servers.palworld = {
        palworldServer = {
            enable = false;
            openFirewall = false;
            port = 8211;
            worldSettings = {
                # see https://palworld.wiki.gg/wiki/PalWorldSettings.ini
            };
        };
    };
}
