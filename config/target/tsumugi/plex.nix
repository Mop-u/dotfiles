{ inputs, config, pkgs, lib, target, ... }:
{
    services.plex = {
        enable = true;
        openFirewall = true;
        extraScanners = [
            inputs.plexASS
        ];
        extraPlugins = [
            (builtins.path {
                name = "Hama.bundle";
                path = inputs.plexHama;
            })
        ];
    };
    services.radarr = {
        enable = true;
        openFirewall = true; # 7878
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
        openFirewall = true; # 5055
    };
    
    #services.deluge = {
    #    enable = true;
    #    declarative = true;
    #    web.enable = true;
    #    web.openFirewall = false; # 8112
    #    config = {
    #        enabled_plugins = [
    #            "Label"
    #        ];
    #    };
    #};


    networking.firewall.allowedTCPPorts = [ 8998 ];

    networking.nat = {
        enable = true;
        enableIPv6 = true;
        internalInterfaces = ["ve-+"];
        externalInterface = "enp6s0";
    };

    containers.sonarrStd = {
        
        autoStart = true;
        privateNetwork = true;
        hostAddress = "192.168.168.10";
        localAddress = "192.168.168.11";
        hostAddress6 = "fc00::10";
        localAddress6 = "fc00::11";

        forwardPorts = [{
            containerPort = 8989;
            hostPort = 8998;
            protocol = "tcp";
        }];

        config = {
            system.stateVersion = target.stateVer;
            networking = {
                firewall.enable = true;
                # Use systemd-resolved inside the container
                # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
                useHostResolvConf = lib.mkForce false;
            };
            services.resolved.enable = true;

            services.sonarr = {
                enable = true;
                openFirewall = true;
            };
        };
    };

    #containers.sonarrAnime = {
    #};
    #containers.radarrStandard = {
    #};
    #containers.radarrAnime = {
    #};
}
