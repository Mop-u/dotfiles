{ inputs, config, pkgs, lib, target, ... }:
{
    services.iperf3 = {
        enable = true;
        openFirewall = true; # 5201
    };
}
