{ inputs, config, pkgs, lib, target, ... }: 
let
    portRemap = configuration: {
        autoStart = true;
        privateNetwork = true;
        hostAddress = "192.168.${toString configuration.id}.10";
        localAddress = "192.168.${toString configuration.id}.11";
        hostAddress6 = "fc00::${toString configuration.id}:10";
        localAddress6 = "fc00::${toString configuration.id}:11";
        forwardPorts = [{
            containerPort = configuration.containerPort;
            hostPort = configuration.hostPort;
            protocol = "tcp";
        }];
        bindMounts."/mnt/media" = {
            mountPoint = "/mnt/media";
            hostPath = "/mnt/media";
            isReadOnly = false;
        };
        config = {
            system.stateVersion = target.stateVer;
            networking = {
                firewall.enable = true;
                useHostResolvConf = lib.mkForce false;
                nameservers = [
                    "10.0.4.1"
                    "2001:bb6:9533:4002::1"
                ];
            };
        } // configuration.config;
    };
in {

    # needed for sonarr
    nixpkgs.config.permittedInsecurePackages = [
        "aspnetcore-runtime-wrapped-6.0.36"
        "aspnetcore-runtime-6.0.36"
        "dotnet-sdk-wrapped-6.0.428"
        "dotnet-sdk-6.0.428"
    ];

    networking.firewall.allowedTCPPorts = [ 
        8112  # deluge
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

    containers.deluge = {
        autoStart = true;
        privateNetwork = false;
        bindMounts."/mnt/media" = {
            mountPoint = "/mnt/media";
            hostPath = "/mnt/media";
            isReadOnly = false;
        };
        config = {
            system.stateVersion = target.stateVer;
            services.deluge = {
                enable = true;
                web.enable = true;
                web.openFirewall = true; # 8112
                config.enabled_plugins = [ "Label" ];
                #authFile = config.sops.templates.delugeAuthFile.path;
            };
        };
    };

    networking = {
        nat = {
            enable = true;
            enableIPv6 = true;
            internalInterfaces = [ "ve-*" ]; # wildcard: use * for nftables, + for iptables
            externalInterface = "enp6s0";
        };
        #networkmanager.unmanaged = [ "interface-name:ve-*" ];
    };

    containers.sonarrAnime = portRemap {
        id = 1;
        containerPort = 8989;
        hostPort = 8998;
        config = {
            nixpkgs.config.permittedInsecurePackages = [
                "aspnetcore-runtime-wrapped-6.0.36"
                "aspnetcore-runtime-6.0.36"
                "dotnet-sdk-wrapped-6.0.428"
                "dotnet-sdk-6.0.428"
            ];
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
