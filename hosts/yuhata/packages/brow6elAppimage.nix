{
  lib,
  appimageTools,
  fetchurl,
}:
let
  pname = "brow6el";
  version = "0.3.4";
  src = fetchurl {
    url = "https://www.brow6el.dev/appimage/brow6el-x86_64.AppImage";
    hash = "sha256-PODwaBKc7hqzPJxBkKn8asHHtsO8hQ7O99G/HZ31e4k=";
  };
in
appimageTools.wrapType2 {
  inherit pname version src;
  extraPkgs = pkgs: [
    pkgs.avahi
    pkgs.gnutls
    pkgs.libxau
    pkgs.libxdmcp
  ];
}
