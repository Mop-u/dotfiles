{
    osConfig,
    config,
    pkgs,
    inputs,
    lib,
    ...
}:
{
    imports = [
        ./wayvr.nix
    ];
    home.packages = with pkgs; [
        nix-index
        bs-manager
        via
        qmk
        (limo.override { withUnrar = true; })
        veadotube
        (pkgs.callPackage ../packages/rootapp.nix { })
        wl-clipboard
    ];
    programs.mangohud.enable = true;
}
