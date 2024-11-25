{ inputs, config, pkgs, lib, target, ... }: 
let
    portRemap = configuration: {
        autoStart = true;
        privateNetwork = true;
        hostAddress = "192.168.${toString configuration.id}.10";
        localAddress = "192.168.${toString configuration.id}.11";
        forwardPorts = [{
            containerPort = configuration.containerPort;
            hostPort = configuration.hostPort;
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
        } // configuration.config;
    };
in {

    networking.firewall.allowedTCPPorts = [ 
        8998  # sonarrAnime
        7887  # radarrAnime
        29347 # deluge incoming
    ];
    networking.firewall.allowedUDPPorts = [ 
        29347 # deluge incoming
    ];

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

    services.sonarr = {
        enable = true;
        openFirewall = true; # 8989
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
    
    #sops.secrets."tsumugi/delugePass" = {};
    #sops.templates.delugeAuthFile = {
    #    owner = "deluge";
    #    content = ''
    #        localclient:${config.sops.placeholder."tsumugi/delugePass"}:10
    #    '';
    #};

    services.deluge = {
        enable = true;
        web.enable = true;
        web.openFirewall = true; # 8112
    };

    networking.nat = {
        enable = true;
        enableIPv6 = false;
        internalInterfaces = ["ve-+"];
        externalInterface = "enp6s0";
    };


    containers.sonarrAnime = portRemap {
        id = 1;
        containerPort = 8989;
        hostPort = 8998;
        config = {
            services.sonarr = {
                enable = true;
                openFirewall = true;
            };
        };
    };

    containers.radarrAnime = portRemap {
        id = 2;
        containerPort = 7878;
        hostPort = 7887;
        config = {
            services.radarr = {
                enable = true;
                openFirewall = true;
            };
        };
    };


}
