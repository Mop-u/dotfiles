{ inputs, config, pkgs, lib, target, ... }: 
{
    sops.secrets."tsumugi/wgpk" = {};
    sops.secrets."ochiai/ip" = {};
    sops.templates.ochiaiWgQuick.content = ''
        [Interface]
        ListenPort = 9546
        Address = 10.0.0.2/24
        PrivateKey = ${config.sops.placeholder."tsumugi/wgpk"}
        Table = 1234
        PostUp = ip rule add pref 500 from 10.0.0.2 lookup 1234
        PostDown = ip rule delete pref 500

        [Peer]
        PublicKey = UoMs4Mtp59wHfJwGLygNe01W3vrBXEevEElZ+rs27Xs=
        AllowedIPs = 0.0.0.0/0
        Endpoint = ${config.sops.placeholder."ochiai/ip"}:5964
        PersistentKeepalive = 25
    '';
    networking.firewall.allowedUDPPorts = [ 9546 ];
    networking.wg-quick.interfaces.ochiai.configFile = config.sops.templates.ochiaiWgQuick.path;

    sops.secrets."tsumugi/cloudflare" = {
        owner = "cloudflared";
    };
    services.cloudflared = {
        enable = true;
        tunnels.tsumugi.credentialsFile = config.sops.secrets."tsumugi/cloudflare".path;
    };
}