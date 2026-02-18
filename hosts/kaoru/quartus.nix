{
    config,
    pkgs,
    inputs,
    lib,
    ...
}:
{
    environment.systemPackages = [
        pkgs.quartus-prime-pro
    ];

}
