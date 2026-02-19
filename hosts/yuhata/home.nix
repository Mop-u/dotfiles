{
    osConfig,
    config,
    pkgs,
    lib,
    ...
}:
{
    home.packages = with pkgs; [
        nix-index
        bs-manager
        via
        qmk
        (limo.override { withUnrar = true; })
        veadotube
        (pkgs.callPackage ./packages/rootapp.nix { })
    ];
}
