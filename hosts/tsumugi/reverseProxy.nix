{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  sops.secrets."tsumugi/wgpk" = { };
  networking.firewall.allowedUDPPorts = [ 9546 ];
  networking.wg-quick.interfaces.ochiai = {
    listenPort = 9546;
    address = [ "10.0.0.2/24" ];
    privateKeyFile = config.sops.secrets."tsumugi/wgpk".path;
    table = "1234";
    postUp = "ip rule add pref 500 from 10.0.0.2 lookup 1234";
    postDown = "ip rule delete pref 500";
    peers = [
      {
        publicKey = "UoMs4Mtp59wHfJwGLygNe01W3vrBXEevEElZ+rs27Xs=";
        allowedIPs = [ "0.0.0.0/0" ];
        endpoint = "ochiai.moppu.dev:5964";
        persistentKeepalive = 25;
      }
    ];
  };

  sops.secrets."tsumugi/cloudflare" = {
    #owner = "cloudflared";
  };
  services.cloudflared = {
    enable = true;
    tunnels.tsumugi = {
      credentialsFile = config.sops.secrets."tsumugi/cloudflare".path;
      default = "http_status:404";
    };
  };
  services.netbird = {
    useRoutingFeatures = "both";
    clients = {
      sidonia = {
        port = 51820;
        login = {
          enable = true;
          setupKeyFile = "${pkgs.writeText "one-time-key" "55E39BBC-B480-4272-9577-B7046E432A3F"}";
        };
        environment = {
          NB_MANAGEMENT_URL = "https://netbird.moppu.dev";
          NB_ADMIN_URL = "https://netbird.moppu.dev";
        };
        openFirewall = true;
        openInternalFirewall = true;
      };
      wt0 = {
        port = 51821;
        login = {
          enable = true;
          setupKeyFile = "${pkgs.writeText "one-time-key" "5EA0A6CF-1610-4E9A-9AC3-DD0F139A1928"}";
        };
        openFirewall = true;
        openInternalFirewall = true;
      };
    };
  };
}
