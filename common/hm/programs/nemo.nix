{
  osConfig,
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = osConfig.sidonia;
  nemoBasePackage = pkgs.nemo;
  nemoPackage =
    (pkgs.nemo-with-extensions.overrideAttrs { extraNativeBuildInputs = [ pkgs.gvfs ]; }).override
      {
        nemo = nemoBasePackage;
        extensions = with pkgs; [
          folder-color-switcher
          nemo-emblems
          nemo-fileroller
          nemo-python
          nemo-preview
        ];
        useDefaultExtensions = false;
      };
in
lib.mkIf (cfg.desktop.enable) {
  home.packages = with pkgs; [
    engrampa # archive manager
    ffmpegthumbnailer
    webp-pixbuf-loader
    nemoPackage
  ];
  xdg = {
    systemDirs.data = [
      "${nemoPackage}/share/gsettings-schemas/nemo-${nemoBasePackage.version}"
    ];
    mimeApps.defaultApplications =
      let
        fileExplorer = "nemo.desktop";
      in
      {
        "inode/directory" = [ fileExplorer ];
        "application/x-gnome-saved-search" = [ fileExplorer ];
      };
  };
}
