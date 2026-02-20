{
    config,
    pkgs,
    inputs,
    lib,
    ...
}:
{
    environment.systemPackages = [
        (pkgs.mkQuartus { quartusSource = pkgs.quartusSources.pro.latestWithDevices [ "cyclone10gx" ]; })
    ];

}
