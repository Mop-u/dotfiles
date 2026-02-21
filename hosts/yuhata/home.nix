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
        wl-clipboard
    ];
    programs.noctalia-shell =
        let
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        in
        {
            plugins = {
                states = {
                    catwalk = {
                        enabled = true;
                        inherit sourceUrl;
                    };
                };
            };
            pluginSettings = {
                catwalk = {
                    minimumThreshold = 25;
                    hideBackground = true;
                };
            };
        };
}
