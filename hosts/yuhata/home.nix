{
    osConfig,
    config,
    pkgs,
    lib,
    ...
}:
{
    home.packages = with pkgs; [
        bs-manager
        via
        qmk
        limo
    ];
}
