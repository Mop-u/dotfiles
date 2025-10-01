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
                    "2001:bb6:9540:502::1"
                ];
            };
        }
        // configuration.config;
    };
in
{
    imports = [
        ./recyclarr/radarrMain.nix
        ./recyclarr/radarrAnime.nix
        ./recyclarr/sonarrAnime.nix
    ];

    networking.firewall.allowedTCPPorts = [
        8998 # sonarrAnime
        7887 # radarrAnime
    ];

    sops.secrets = {
        "tsumugi/autobrrSecret" = { };
        "tsumugi/sonarrMainApiKey" = { };
    };

    services.plex = {
        enable = true;
        openFirewall = true;
    };

    services.jellyfin = {
        enable = false;
        openFirewall = true;
        cacheDir = "/mnt/media/data/appdata/jellyfin/cache";
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

    systemd.services.recyclarr.serviceConfig.LoadCredential = [
        "sonarrMainApiKey:${config.sops.secrets."tsumugi/sonarrMainApiKey".path}"
    ];
    services.recyclarr = {
        enable = true;
        # configuration =
        #     let
        #        profileName = "recyclarr";
        #        mkScorer = profile: ids: score: {
        #            trash_ids = ids;
        #            assign_scores_to = [
        #                {
        #                    name = profile;
        #                    score = score;
        #                }
        #            ];
        #        };
        #        mkScores = mkScorer profileName;
        #        mkScore = id: (mkScores [ id ]);
        #     in
        #     {
        #         sonarr.sonarrMain = {
        #             base_url = "http://localhost:8989";
        #             api_key._secret = "/run/credentials/recyclarr.service/sonarrMainApiKey";
        #         };
        #     };
    };

}
