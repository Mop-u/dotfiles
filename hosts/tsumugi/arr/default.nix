{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
{
    imports = [
        ./radarrMain.nix
        ./radarrAnime.nix
        ./sonarrAnime.nix
        ./sonarrMain.nix
    ];

    sops.secrets."tsumugi/autobrrSecret" = { };

    services.plex = {
        enable = true;
        openFirewall = true;
    };

    services.jellyfin = {
        enable = false;
        openFirewall = true;
        cacheDir = "/mnt/media/data/appdata/jellyfin/cache";
    };

    services.prowlarr = {
        enable = true;
        openFirewall = true; # 9696
    };
    services.bazarr = {
        enable = true;
        openFirewall = true; # 6767
    };
    services.jellyseerr = {
        enable = true;
        port = 5055;
        openFirewall = true;
    };

    services.recyclarr = {
        enable = true;
    };

    services.autobrr = {
        enable = true;
        openFirewall = true; # 7474
        secretFile = config.sops.secrets."tsumugi/autobrrSecret".path;
        settings = {
            host = "10.0.4.2";
            port = 7474;
        };
    };

    networking = {
        nat =
            let
                wildcard = if config.networking.nftables.enable then "*" else "+";
            in
            {
                enable = true;
                enableIPv6 = true;
                internalInterfaces = [ ("ve-" + wildcard) ];
                externalInterface = "enp6s0";
            };
        #networkmanager.unmanaged = [ "interface-name:ve-*" ];
    };

}
