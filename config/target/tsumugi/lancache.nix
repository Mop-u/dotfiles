{ inputs, config, pkgs, lib, target, ... }:
{
    lancache.dns = {
        enable = true;
        forwarders = [ "10.0.4.1" ];
        cacheIp = "10.0.4.2";
        #cacheIp6 = "fe80::e154:9dfe:dd4f:a1d5";
        cacheNetworks = [
            "10.0.4.0/24"
            "fe80::/10"
            "2001:bb6:9533:4002::/64"
            "127.0.0.0/24"
            "::1/128"
        ];
    };
    
    lancache.cache = {
        enable = true;
        resolvers = [ "10.0.4.1" ];
        cacheDiskSize = "8000g";
        cacheIndexSize = "2000m";
        nginxWorkerProcesses = "4";
        cacheDir = "/mnt/lancache";
    };
    services.resolved.extraConfig = ''
        DNSStubListener=no
    '';
    systemd.services.nginx.serviceConfig.LimitNOFILE = 65535;
}
