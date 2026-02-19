{
    lib,
    appimageTools,
    fetchurl,
}:
let
    pname = "rootapp";
    version = "0.9.92";
    src = fetchurl {
        url = "https://installer.rootapp.com/installer/Linux/X64/Root.AppImage";
        hash = "sha256-rvuFNmfDkmtgV7V7fCcYRHvUAy43GkMwJfKSMyIdMNc=";
    };
in
appimageTools.wrapType2 {
    inherit pname version src;
}
