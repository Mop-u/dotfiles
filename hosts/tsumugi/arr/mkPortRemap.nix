{
    config,
    lib,
}:
{
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
}
