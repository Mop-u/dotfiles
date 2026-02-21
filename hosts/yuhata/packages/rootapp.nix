{
    lib,
    appimageTools,
    fetchurl,
}:
let
    pname = "rootapp";
    version = "0.9.93";
    src = fetchurl {
        url = "https://installer.rootapp.com/installer/Linux/X64/Root.AppImage";
        hash = "sha256-ejlytvqMnsD6UPKMxjstx1oMIbEPAqFR5W983WhEGAM=";
    };
in
appimageTools.wrapType2 {
    inherit pname version src;
}
