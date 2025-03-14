{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
{
    services.iperf3 = {
        enable = true;
        openFirewall = true; # 5201
    };
}
