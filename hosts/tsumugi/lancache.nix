{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
let
    enable = false;
in
{
    imports = [
        inputs.lancache.nixosModules.dns
        inputs.lancache.nixosModules.cache
    ];
    services.lancache.dns = {
        inherit enable;
        forwarders = [
            "10.0.4.1"
            "fe80::e638:83ff:fe96:6a8b%enp6s0"
        ];
        cacheIp = "10.0.4.2";
        #cacheIp6 = "fe80::e154:9dfe:dd4f:a1d5";
        cacheNetworks = [
            "10.0.4.0/24"
            "fe80::/10"
            "2001:bb6:9540:502::/64"
            "127.0.0.0/24"
            "::1/128"
        ];
    };

    services.lancache.cache = {
        inherit enable;
        resolvers = [ "10.0.4.1" ];
        cacheDiskSize = "8000g";
        cacheIndexSize = "2000m";
        cacheDir = "/mnt/lancache/cache";
        #logDir = "/mnt/lancache/log"; # nginx doesn't like network drive for logging
    };
    services.resolved.extraConfig = ''
        DNSStubListener=no
    '';
    systemd.services.nginx.serviceConfig.LimitNOFILE = 65535;
}
