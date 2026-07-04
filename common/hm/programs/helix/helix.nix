{
  osConfig,
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.helix = {
    enable = lib.mkDefault true;
    package = lib.mkDefault pkgs.helix-unstable;
    defaultEditor = lib.mkDefault true;
    extraPackages = with pkgs; [
      vhdl-ls # vhdl
      clang-tools # c/cpp/opencl
      neocmakelsp # cmake
      vscode-json-languageserver # json
      nixd # nix
      nixfmt # nix
      marksman # markdown
      zls # zig
      lldb # various debuggers
      yaml-language-server
      yamlfmt
    ];
    settings = {
      editor = {
        bufferline = "multiple";
      };
      keys.normal = lib.mkMerge [
        (lib.mkIf config.programs.lazygit.enable {
          "C-g" = [
            ":write-all"
            ":new"
            ":insert-output ${lib.getExe config.programs.lazygit.package}"
            ":buffer-close!"
            ":redraw"
            ":reload-all"
          ];
        })
      ];
    };
  };
}
