{
  osConfig,
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = osConfig.sidonia;
in
lib.mkIf (cfg.desktop.enable) {
  programs.vscodium = {
    enable = lib.mkDefault true;
    profiles.default = {
      enableExtensionUpdateCheck = false;
      enableUpdateCheck = false;
      extensions = with pkgs.vsxExtensionsFor config.programs.vscodium.package; [
        haskell.haskell
        jnoortheen.nix-ide
        mkhl.direnv
      ];
      userSettings =
        let
          nixfmt = [
            "nixfmt"
            "--indent=4"
          ];
        in
        {
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
                autoEvalInputs = false;
                nixpkgsInputName = "nixpkgs";
              };
            };
          };
          "editor.fontFamily" = "monospace, 'ComicShannsMono Nerd Font'";
        };
    };
  };
}
