{
  config,
  lib,
}:
let
  inherit (config) system;
in
{
  portRemap =
    {
      id,
      containerPort,
      hostPort,
      config ? { },
      ...
    }:
    {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.${toString id}.10";
      localAddress = "192.168.${toString id}.11";
      hostAddress6 = "fc00::${toString id}:10";
      localAddress6 = "fc00::${toString id}:11";
      forwardPorts = [
        {
          containerPort = containerPort;
          hostPort = hostPort;
          protocol = "tcp";
        }
      ];
      bindMounts."/mnt/media" = {
        mountPoint = "/mnt/media";
        hostPath = "/mnt/media";
        isReadOnly = false;
      };
      config = lib.mkMerge [
        {
          system = { inherit (system) stateVersion; };
          networking = {
            firewall.enable = true;
            useHostResolvConf = lib.mkForce false;
            nameservers = [
              "10.0.4.1"
              "2001:bb6:9540:502::1"
            ];
          };
        }
        config
      ];
    };
}
