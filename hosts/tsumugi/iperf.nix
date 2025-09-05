{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
{
    services.iperf3 = {
        enable = false;
        openFirewall = true; # 5201
    };
}
