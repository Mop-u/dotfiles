{ inputs, config, pkgs, lib, target, ... }: 
let
    portRemap = configuration: {
        autoStart = true;
        privateNetwork = true;
        hostAddress = "192.168.168.${toString (configuration.id)}";
        localAddress = "192.168.168.${toString (configuration.id+128)}";
        hostAddress6 = "fc00::${toString (configuration.id)}";
        localAddress6 = "fc00::${toString (configuration.id+128)}";
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

    networking.nat = {
        enable = true;
        enableIPv6 = true;
        internalInterfaces = ["ve-+"];
        externalInterface = "enp6s0";
    };

    networking.firewall.allowedTCPPorts = [ 8998 7887 ];

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
