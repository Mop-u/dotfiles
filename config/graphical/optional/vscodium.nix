{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
let
    cfg = config.sidonia;
    theme = cfg.style.catppuccin;
in
{
    options.sidonia.programs.vscodium.enable =
        with lib;
        mkOption {
            type = types.bool;
            default = cfg.graphics.enable;
        };
    config = lib.mkIf (cfg.programs.vscodium.enable) {
        nixpkgs.overlays = [
            (final: prev: {
                vscodium = inputs.nixpkgs-unstable.legacyPackages.${final.system}.vscodium;
            })
            (
                final: prev:
                let
                    version = lib.versions.pad 3 final.vscodium.version;
                    flakeExts = inputs.nix-vscode-extensions.extensions.${final.system}.forVSCodeVersion version;

                    catppuccin-vsc-override = {
                        catppuccin.catppuccin-vsc = inputs.catppuccin-vsc.packages.${final.system}.default.override {
                            accent = theme.accent;
                            boldKeywords = true;
                            italicComments = true;
                            italicKeywords = true;
                            extraBordersEnabled = false;
                            workbenchMode = "default";
                            bracketMode = "rainbow";
                            colorOverrides = { };
                            customUIColors = { };
                        };
                    };
                in
                {
                    vscode-extensions =
                        with flakeExts;
                        lib.zipAttrsWith (name: values: (lib.mergeAttrsList values)) [
                            prev.vscode-extensions
                            open-vsx
                            open-vsx-release
                            vscode-marketplace
                            vscode-marketplace-release
                            catppuccin-vsc-override
                        ];
                }
            )
        ];
        home-manager.users.${cfg.userName} = {
            programs.vscode = {
                enable = true;
                enableExtensionUpdateCheck = false;
                enableUpdateCheck = false;
                package = pkgs.vscodium;
                extensions = with pkgs.vscode-extensions; [
                    haskell.haskell
                    jnoortheen.nix-ide
                    llvm-vs-code-extensions.vscode-clangd
                    mkhl.direnv
                    mshr-h.veriloghdl
                    ms-vscode.live-server
                    gruntfuggly.triggertaskonsave
                    catppuccin.catppuccin-vsc-icons
                    catppuccin.catppuccin-vsc
                    christian-kohler.path-intellisense
                ];
                userSettings =
                    let
                        nixfmt = [
                            "nixfmt"
                            "--indent=4"
                        ];
                    in
                    {
                        "workbench.iconTheme" = "catppuccin-${theme.flavor}";
                        "workbench.colorTheme" = "Catppuccin ${cfg.lib.capitalize theme.flavor}";
                        "typescript.suggest.paths" = false;
                        "javascript.suggest.paths" = false;
                        "nix.enableLanguageServer" = true;
                        "nix.formatterPath" = nixfmt;
                        "nix.serverPath" = "nil";
                        "nix.serverSettings" = {
                            nil = {
                                diagnostics.ignored = [
                                    "unused_binding"
                                    "unused_with"
                                ];
                                formatting.command = nixfmt;
                                nix.flake = {
                                    autoArchive = true;
                                    autoEvalInputs = true;
                                    nixpkgsInputName = "nixpkgs";
                                };
                            };
                        };
                        "editor.fontFamily" = "monospace, 'ComicShannsMono Nerd Font'";
                    };
            };
        };
    };
}
