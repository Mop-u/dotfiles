{
    config,
    pkgs,
    inputs,
    lib,
    ...
}:
{
    environment.systemPackages = [
        (pkgs.mkQuartus { quartusSource = pkgs.quartusSources.pro."25.3.0.109"; })
    ];

}
