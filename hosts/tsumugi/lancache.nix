{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
let
    enable = true;
    nameservers = [ "10.0.4.1" ];
in
{
    imports = [
        inputs.lancache.nixosModules.dns
        inputs.lancache.nixosModules.cache
    ];
    networking = { inherit nameservers; };
    services.lancache.dns = {
        inherit enable;
        forwarders = nameservers;
        cacheIp = "10.0.4.2";
    };
    services.lancache.cache = {
        inherit enable;
        resolvers = nameservers;
        cacheDiskSize = "8000g";
        cacheIndexSize = "2000m";
        cacheDir = "/mnt/lancache/cache";
        nginxWorkerProcesses = builtins.toString 8;
        cacheSliceSize = "4m";
    };
    services.resolved.extraConfig = ''
        DNSStubListener=no
    '';
    systemd = {
        tmpfiles.rules = [
            "d ${config.services.lancache.cache.logDir} - nginx nginx"
        ];
        services.nginx.serviceConfig = {
            LimitNOFILE = 65535;
            ReadWritePaths = [
                config.services.lancache.cache.logDir
                config.services.lancache.cache.cacheDir
            ];
        };
    };
    services.nginx = {
        proxyResolveWhileRunning = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;
        recommendedOptimisation = true;
        recommendedGzipSettings = true;
        recommendedBrotliSettings = true;
        recommendedUwsgiSettings = true;
        appendConfig = ''
            worker_rlimit_nofile 65535;
        '';
        appendHttpConfig = ''
            access_log off;
            proxy_buffer_size 64k;
            proxy_buffers 8 64k;
            proxy_busy_buffers_size 128k;
        '';
    };
}
