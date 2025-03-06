{inputs, config, pkgs, lib, ... }: let
    cfg = config.sidonia;
    theme = cfg.style.catppuccin;
in {
    options.sidonia.programs.vscodium.enable = with lib; mkOption {
        type = types.bool;
        default = cfg.graphics.enable;
    };
    config = lib.mkIf (cfg.programs.vscodium.enable) {
        nixpkgs.overlays = [
            (final: prev: let
                system = final.system;
                vscodium = final.vscodium;
                flakeExts = inputs.nix-vscode-extensions.extensions.${system}.forVSCodeVersion vscodium.version;

                catppuccin-vsc-override = {
                    catppuccin.catppuccin-vsc = inputs.catppuccin-vsc.packages.${system}.default.override {
                        accent = theme.accent;
                        boldKeywords = true;
                        italicComments = true;
                        italicKeywords = true;
                        extraBordersEnabled = false;
                        workbenchMode = "default";
                        bracketMode = "rainbow";
                        colorOverrides = {};
                        customUIColors = {};
                    };
                };
            in {
                vscode-extensions = with flakeExts; lib.zipAttrsWith (name: values: (lib.mergeAttrsList values))[
                    prev.vscode-extensions
                    vscode-marketplace-release
                    vscode-marketplace
                    catppuccin-vsc-override
                ];
            })
        ];
        home-manager.users.${cfg.userName} = {
            programs.vscode = {
                enable = true;
                enableExtensionUpdateCheck = true;
                enableUpdateCheck = true;
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
                ];
            };
        };
    };
}
