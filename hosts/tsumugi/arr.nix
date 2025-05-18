{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
let
    portRemap = configuration: {
        autoStart = true;
        privateNetwork = true;
        hostAddress = "192.168.${builtins.toString configuration.id}.10";
        localAddress = "192.168.${builtins.toString configuration.id}.11";
        hostAddress6 = "fc00::${builtins.toString configuration.id}:10";
        localAddress6 = "fc00::${builtins.toString configuration.id}:11";
        forwardPorts = [
            {
                containerPort = configuration.containerPort;
                hostPort = configuration.hostPort;
                protocol = "tcp";
            }
        ];
        bindMounts."/mnt/media" = {
            mountPoint = "/mnt/media";
            hostPath = "/mnt/media";
            isReadOnly = false;
        };
        config = {
            system.stateVersion = config.sidonia.stateVer;
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
in
{

    # needed for sonarr
    nixpkgs.config.permittedInsecurePackages = [
        "aspnetcore-runtime-wrapped-6.0.36"
        "aspnetcore-runtime-6.0.36"
        "dotnet-sdk-wrapped-6.0.428"
        "dotnet-sdk-6.0.428"
    ];

    networking.firewall.allowedTCPPorts = [
        8998 # sonarrAnime
        7887 # radarrAnime
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
        port = 5055;
        openFirewall = true;
    };

    sops.secrets."tsumugi/autobrrSecret" = {};
    services.autobrr = {
        enable = true;
        openFirewall = true; # 7474
        secretFile = config.sops.secrets."tsumugi/autobrrSecret".path;
        settings = {
            host = "10.0.4.2";
            port = 7474;
        };
    };

    sops.secrets."tsumugi/transmission" = {};
    services.transmission = {
        enable = true;
        package = pkgs.transmission_4;
        openRPCPort = true;
        openPeerPorts = true;
        credentialsFile = config.sops.secrets."tsumugi/transmission".path;
        settings = let
            speed-limit-enabled = true; # speed limit is in KB/s
            mbits = x: ((x*1000) / 8);
        in {
            # https://github.com/transmission/transmission/blob/main/docs/Editing-Configuration-Files.md
            speed-limit-up = mbits 2;
            speed-limit-down = mbits 20;
            speed-limit-up-enabled = speed-limit-enabled;
            speed-limit-down-enabled = speed-limit-enabled;
            download-queue-enabled = false;
            incomplete-dir-enabled = false;
            incomplete-dir = "/mnt/media/data/torrents/.incomplete";
            trash-can-enabled = false;
            cache-size-mb = 0; # we have fsc on the network share
            rpc-whitelist-enabled = false;
            rpc-authentication-required = true;
            anti-brute-force-enabled = true;
            rpc-bind-address = "10.0.4.2";
            rpc-port = 9091;
            download-dir = "/mnt/media/data/torrents";
            peer-port = 29347;
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
