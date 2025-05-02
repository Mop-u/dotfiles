{
    config,
    pkgs,
    inputs,
    lib,
    ...
}:
{
    virtualisation.virtualbox.host = {
        enable = true;
        enableExtensionPack = true;
        enableKvm = true;
    };
}
