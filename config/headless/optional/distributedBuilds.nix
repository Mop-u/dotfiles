{
    config,
    pkgs,
    lib,
    otherHosts,
    ...
}:
let
    cfg = config.sidonia;
    forEachOtherHost = f: builtins.map f otherHosts;
in
{
    options.sidonia.services.distributedBuilds = with lib; {
        host = {
            enable = mkEnableOption "Enable becoming a distributed build host";
            user = mkOption {
                type = types.str;
                default = "builder";
            };
            signing = {
                pubKey = mkOption {
                    description = "Public key for store binary cache signing";
                    type = types.str;
                };
                privKeyPath = mkOption {
                    description = "Path to private cache signing key";
                    type = types.path;
                };
            };
            ssh.pubKey = mkOption {
                description = "known_hosts public key";
                type = types.str;
            };
            hostNames = mkOption {
                description = "Hostnames or ip addresses of the build host";
                type = types.listOf types.str;
            };
        };
        client = {
            enable = mkEnableOption "Enable taking advantage of distributed builds";
            ssh = {
                pubKey = mkOption {
                    type = types.str;
                    default = cfg.ssh.pubKey;
                };
                privKeyPath = mkOption {
                    type = types.path;
                    default = cfg.ssh.privKeyPath;
                };
            };
        };
    };

    config =
        let
            host = cfg.services.distributedBuilds.host;
            client = cfg.services.distributedBuilds.client;
        in
        lib.mkMerge [
            (lib.mkIf client.enable (
                lib.mkMerge (
                    (forEachOtherHost (
                        remote:
                        let
                            remoteHost = remote.config.sidonia.services.distributedBuilds.host;
                            builderName = "${remoteHost.user}_at_${remote.config.sidonia.hostName}";
                        in
                        lib.mkIf remoteHost.enable {
                            programs.ssh = {
                                knownHosts = {
                                    ${builderName} = {
                                        extraHostNames = remoteHost.hostNames;
                                        publicKey = remoteHost.ssh.pubKey;
                                    };
                                };
                                extraConfig = ''
                                    Host ${builderName}
                                        User ${remoteHost.user}
                                        Hostname ${builtins.head remoteHost.hostNames}
                                        IdentitiesOnly yes
                                        IdentityFile ${client.ssh.privKeyPath}
                                '';
                            };
                            nix = {
                                settings = {
                                    trusted-public-keys = [ remoteHost.signing.pubKey ];
                                    substituters = [ "ssh-ng://${builderName}" ];
                                };
                                buildMachines = [
                                    {
                                        hostName = builtins.head remoteHost.hostNames;
                                        sshUser = remoteHost.user;
                                        sshKey = client.ssh.privKeyPath;
                                        #publicHostKey = remoteHost.ssh.pubKey; # don't use this value as it wants base64, fall back to known_hosts instead
                                        system = "x86_64-linux";
                                        protocol = "ssh-ng";
                                        maxJobs = 1;
                                        speedFactor = 2;
                                        supportedFeatures = [
                                            "nixos-test"
                                            "benchmark"
                                            "big-parallel"
                                            "kvm"
                                        ];
                                    }
                                ];
                            };
                        }
                    ))
                    ++ [
                        {
                            nix.distributedBuilds = true;
                        }
                    ]
                )
            ))
            (lib.mkIf host.enable (
                lib.mkMerge (
                    (forEachOtherHost (
                        remote:
                        let
                            remoteClient = remote.config.sidonia.services.distributedBuilds.client;
                        in
                        lib.mkIf remoteClient.enable {
                            users.users.${host.user}.openssh.authorizedKeys.keys = [ remoteClient.ssh.pubKey ];
                        }
                    ))
                    ++ [
                        {
                            users.users.${host.user}.isNormalUser = true;
                            services.openssh.settings.AllowUsers = [ host.user ];
                            nix.settings.secret-key-files = host.signing.privKeyPath;
                            nix.settings.trusted-users = [ host.user ];
                        }
                    ]
                )
            ))
        ];
}
