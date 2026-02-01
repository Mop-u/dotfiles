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
        limo
        (pkgs.callPackage ./packages/veadotube.nix {})
    ];
    services.hyprpolkitagent.enable = true;
}
