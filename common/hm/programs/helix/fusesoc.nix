{
  osConfig,
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.helix = {
    languages.language = [
      {
        name = "yaml";
        # https://github.com/helix-editor/helix/blob/460d3be574a514d327ea5e55a50dc4fea67d60fc/languages.toml#L1672
        file-types = [
          "core" # fusesoc core
          "yml"
          "yaml"
          { glob = ".prettierrc"; }
          { glob = ".clangd"; }
          { glob = ".clang-format"; }
          { glob = ".clang-tidy"; }
          { glob = ".gem/credentials"; }
          { glob = ".kube/config"; }
          { glob = ".kube/kuberc"; }
          { glob = "yarn.lock"; }
          "sublime-syntax"
          "bu"
          { glob = ".stylelintrc"; } # https://stylelint.io/user-guide/configure/
          { glob = ".puppeteerrc"; } # https://pptr.dev/guides/configuration
        ];
      }
    ];
  };
}
