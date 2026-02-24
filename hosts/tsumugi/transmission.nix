{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
{
    sops.secrets."tsumugi/transmission" = {
        restartUnits = [ "container@transmission.service" ];
    };
    sops.secrets."tsumugi/transmissionwgpk" = {
        restartUnits = [ "container@transmission.service" ];
    };

    networking.firewall.allowedTCPPorts = [ 9092 ];

    containers.transmission =
        let
            realSubnet = "10.0.4.0/24";
            containerSubnet = "192.168.0.0/16";
            hostAddress = "192.168.100.10";
            localAddress = "192.168.100.11";
            hostPort = 9092;
            localPort = 9091;
            inherit (config.sidonia.lib) configContainerCredential;
        in
        lib.mkMerge [
            {
                autoStart = true;
                privateNetwork = true;
                inherit hostAddress;
                inherit localAddress;
                forwardPorts = [
                    {
                        containerPort = localPort;
                        hostPort = hostPort;
                        protocol = "tcp";
                    }
                ];
                bindMounts."/mnt/media".isReadOnly = false;
                config = {
                    system = {inherit (config.system) stateVersion;};
                    networking = {
                        firewall.enable = true;
                        useHostResolvConf = lib.mkForce false;
                        nameservers = [ "10.0.4.1" ];
                    };
                };
            }
            (configContainerCredential (cred: {
                networking.wg-quick.interfaces.wg0 = {
                    privateKeyFile = cred;
                    address = [ "10.2.0.2/32" ];
                    dns = [ "10.2.0.1" ];
                    postUp = ''
                        ip route add ${realSubnet} via ${hostAddress}
                        ip route add ${containerSubnet} via ${hostAddress}
                    '';
                    preDown = ''
                        ip route delete ${realSubnet}
                        ip route delete ${containerSubnet}
                    '';
                    peers = [
                        {
                            publicKey = "YWMbt8hivy0dAHCuK4wFqKFZ54BhlsrLYR07xJzPAQc=";
                            allowedIPs = [ "0.0.0.0/0" ];
                            endpoint = "79.127.145.65:51820";
                        }
                    ];
                };
            }) "wg-quick-wg0" config.sops.secrets."tsumugi/transmissionwgpk".path)
            (configContainerCredential (cred: {
                systemd.services.transmission = {
                    serviceConfig = {
                        # https://github.com/NixOS/nixpkgs/issues/258793
                        RootDirectoryStartOnly = lib.mkForce false;
                        RootDirectory = lib.mkForce "";
                        PrivateMounts = lib.mkForce false;
                        PrivateUsers = lib.mkForce false;
                    };
                };
                services.transmission = {
                    credentialsFile = cred;
                    enable = true;
                    package =
                        let
                            transmission_4_0_5 =
                                (
                                    (import (
                                        pkgs.fetchFromGitHub {
                                            owner = "NixOS";
                                            repo = "nixpkgs";
                                            rev = "4a3fc4cf736b7d2d288d7a8bf775ac8d4c0920b4";
                                            hash = "sha256-KkT6YM/yNQqirtYj/frn6RRakliB8RDvGqVGGaNhdcU=";
                                        }
                                    ))
                                    {
                                        inherit (pkgs.stdenv.hostPlatform) system;
                                    }
                                ).pkgs.transmission_4;
                        in
                        transmission_4_0_5;
                    openRPCPort = true;
                    openPeerPorts = true;
                    settings =
                        let
                            speed-limit-enabled = true; # speed limit is in KB/s
                            mbits = x: ((x * 1000) / 8);
                        in
                        {
                            # https://github.com/transmission/transmission/blob/main/docs/Editing-Configuration-Files.md
                            speed-limit-up = mbits 10;
                            speed-limit-down = mbits 60;
                            speed-limit-up-enabled = speed-limit-enabled;
                            speed-limit-down-enabled = speed-limit-enabled;
                            download-queue-enabled = false;
                            incomplete-dir-enabled = false;
                            incomplete-dir = "/mnt/media/data/torrents/.incomplete";
                            preallocation = 0;
                            trash-can-enabled = false;
                            cache-size-mb = 8192; # avoid accessing the disk too much
                            rpc-whitelist-enabled = false;
                            rpc-authentication-required = true;
                            anti-brute-force-enabled = true;
                            rpc-bind-address = localAddress;
                            rpc-port = localPort;
                            download-dir = "/mnt/media/data/torrents";
                        };
                };
            }) "transmission" config.sops.secrets."tsumugi/transmission".path)
        ];
}
