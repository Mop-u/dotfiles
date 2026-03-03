{
    config,
    pkgs,
    inputs,
    lib,
    ...
}:
{
    virtualisation.virtualbox.host = {
        enable = false;
        enableExtensionPack = true;
        enableKvm = true;
        addNetworkInterface = false;
    };
}
