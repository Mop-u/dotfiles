{inputs, config, pkgs, lib, ... }: let
    cfg = config.sidonia;
    theme = cfg.style.catppuccin;
in {
    options.sidonia.programs.vscodium.enable = with lib; mkOption {
        description = "Enable GoXLR support";
        type = types.bool;
        default = cfg.graphics.enable;
    };
    config = lib.mkIf (cfg.programs.vscodium.enable) {
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
                    catppuccin.catppuccin-vsc-icons
                    (inputs.catppuccin-vsc.packages.${pkgs.system}.default.override {
                        accent = theme.accent;
                        boldKeywords = true;
                        italicComments = true;
                        italicKeywords = true;
                        extraBordersEnabled = false;
                        workbenchMode = "default";
                        bracketMode = "rainbow";
                        colorOverrides = {};
                        customUIColors = {};
                    })
                ];
            };
        };
    };
}
