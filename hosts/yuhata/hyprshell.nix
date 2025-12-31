{
    config,
    pkgs,
    inputs,
    lib,
    ...
}:
{
    home-manager.users.midorikawa = {
        imports = [
            inputs.hyprshell.homeModules.hyprshell
        ];
        # https://github.com/H3rmt/hyprshell/blob/hyprshell-release/nix/module.nix
        programs.hyprshell = {
            enable = true;
            package = inputs.hyprshell.packages.${pkgs.stdenv.hostPlatform.system}.hyprshell-nixpkgs;
            systemd.args = "-v";
            settings = {
                windows = {
                    enable = true;
                    overview = {
                        enable = true;
                        key = "o";
                        modifier = "super";
                        launcher = {
                            default_terminal = "foot";
                            max_items = 6;
                        };
                    };
                    switch.enable = true;
                };
            };
        };
    };
}
