{
    lib,
    appimageTools,
    fetchurl,
}:
let
    pname = "rootapp";
    version = "0.9.99";
    src = fetchurl {
        url = "https://installer.rootapp.com/installer/Linux/X64/Root.AppImage";
        hash = "sha256-lZIZVloM1cq4b5FjeEkYv7BvHD/cmBvPtZcBkXj144U=";
    };

    appimageContents = appimageTools.extract {
        inherit pname version src;
        postExtract = ''
            substituteInPlace $out/Root.desktop --replace-fail 'Exec=Root' 'Exec=rootapp'
        '';
    };
in
appimageTools.wrapType2 {
    inherit pname version src;
    extraInstallCommands = ''
        install -m 444 -D ${appimageContents}/Root.desktop $out/share/applications/Root.desktop
        install -m 444 -D ${appimageContents}/Root.png $out/share/icons/hicolor/512x512/apps/Root.png
    '';
}
