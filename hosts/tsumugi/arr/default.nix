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
  sops.secrets."tsumugi/bandcampCookies".owner = config.users.users.bandcampsync.name;

  services = {
    plex = {
      enable = true;
      openFirewall = true;
    };

    jellyfin = {
      enable = false;
      openFirewall = true;
      cacheDir = "/mnt/media/data/appdata/jellyfin/cache";
    };

    prowlarr = {
      enable = true;
      openFirewall = true; # 9696
    };
    bazarr = {
      enable = true;
      openFirewall = true; # 6767
    };
    seerr = {
      enable = true;
      port = 5055;
      openFirewall = true;
    };

    recyclarr = {
      enable = true;
    };

    autobrr = {
      enable = true;
      openFirewall = true; # 7474
      secretFile = config.sops.secrets."tsumugi/autobrrSecret".path;
      settings = {
        host = "0.0.0.0";
        port = 7474;
      };
    };

    bandcampsync = {
      enable = true;
      settings = {
        cookies = config.sops.secrets."tsumugi/bandcampCookies".path;
        directory = "/mnt/media/data/media/bandcampsync";
        runDailyAt = 3;
        skipHidden = true;
      };
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
