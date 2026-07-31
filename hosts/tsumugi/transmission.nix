{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit ((import ./arr/mkPortRemap.nix) { inherit config lib; }) portRemap;
in
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
      id = 100;
      containerPort = 9091;
      hostAddress = "192.168.${toString id}.10";
      localAddress = "192.168.${toString id}.11";
      hostRoutes = [
        "100.109.0.0/16" # netbird
        "10.0.4.0/24" # home subnet
        "192.168.0.0/16" # container subnet
      ];
      inherit (config.sidonia.lib) configContainerCredential;
    in
    lib.mkMerge [
      (portRemap {
        inherit id containerPort;
        hostPort = 9092;
      })
      (configContainerCredential (cred: {
        networking.wg-quick.interfaces.wg0 = {
          privateKeyFile = cred;
          address = [
            "10.2.0.2/32"
          ];
          dns = [
            "10.2.0.1"
          ];
          postUp = lib.concatLines (map (subnet: "ip route add ${subnet} via ${hostAddress}") hostRoutes);
          preDown = lib.concatLines (map (subnet: "ip route delete ${subnet}") hostRoutes);
          peers = [
            {
              publicKey = "YWMbt8hivy0dAHCuK4wFqKFZ54BhlsrLYR07xJzPAQc=";
              allowedIPs = [
                "0.0.0.0/0"
              ];
              endpoint = "79.127.145.65:51820";
              # endpoint = "[2a02:6ea0:f911:6588::10]:51820";
            }
          ];
        };
      }) "wg-quick-wg0" config.sops.secrets."tsumugi/transmissionwgpk".path)
      (configContainerCredential (cred: {
        systemd.services.transmission = {
          serviceConfig = {
            # https://github.com/NixOS/nixpkgs/issues/258793
            RootDirectoryStartOnly = lib.mkForce null;
            RootDirectory = lib.mkForce null;
          };
        };
        services.transmission = {
          credentialsFile = cred;
          enable = true;
          package = inputs.unstable.legacyPackages.x86_64-linux.transmission_4;
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
              rpc-whitelist-enabled = true;
              rpc-host-whitelist-enabled = false;
              rpc-authentication-required = true;
              anti-brute-force-enabled = true;
              rpc-whitelist = lib.concatStringsSep "," [
                "100.109.*.*"
                "10.0.4.*"
                "192.168.*.*"
              ];
              rpc-bind-address = localAddress;
              rpc-port = containerPort;
              download-dir = "/mnt/media/data/torrents";
            };
        };
      }) "transmission" config.sops.secrets."tsumugi/transmission".path)
    ];
}
