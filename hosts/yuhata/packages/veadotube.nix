{
    lib,
    stdenv,
    unzip,
    fetchurl,
    requireFile,
    autoPatchelfHook,
    makeDesktopItem,

    ffmpeg,
    sdl3,
    rnnoise,
    rtmidi,
    onnxruntime,
    bash,
    file,
    icu,
    freetype,
    harfbuzz,
    wineWowPackages,
}:
stdenv.mkDerivation (finalAttrs: rec {
    pname = "veadotube";
    version = "0.5-20260116a";
    src = requireFile {
        name = "veadotube-labs-veadotube-linux-x64.zip";
        url = "https://veado.tube/";
        hash = "sha256-QKcx9ieXBx2RQUVo5QEAKVdBvB349eFh2ikYux8WYH4=";
    };
    sourceRoot = ".";
    system = "x86_64-linux";
    nativeBuildInputs = [
        autoPatchelfHook
        unzip
    ];
    runtimeDependencies = [
        onnxruntime
        harfbuzz
        freetype
        icu
        sdl3
        rnnoise
        rtmidi
    ];
    buildInputs = runtimeDependencies ++ [
        bash
        file
        ffmpeg
        wineWowPackages.stable
    ];
    installPhase =
        let
            desktopItem = makeDesktopItem {
                name = pname;
                desktopName = "Veadotube";
                icon = fetchurl {
                    url = "https://veado.tube/assets/brand/veadoicon.png";
                    hash = "sha256-nyw+vuch9glw7WP5wIKVfU2Koz2DmWZdHSmQvbKqyvM=";
                };
                exec = meta.mainProgram;
                comment = meta.description;
            };
        in
        ''
            mkdir -p $out/share/${pname}
            cp -r ./* $out/share/${pname}/
            chmod +x $out/share/${pname}/veadotube

            rm $out/share/${pname}/lib/ffmpeg
            ln -s ${lib.getExe ffmpeg} $out/share/${pname}/lib/ffmpeg

            rm $out/share/${pname}/lib/sdl3.so
            ln -s ${sdl3}/lib/libSDL3.so $out/share/${pname}/lib/sdl3.so

            rm $out/share/${pname}/lib/rnnoise.so
            ln -s ${rnnoise}/lib/librnnoise.so $out/share/${pname}/lib/rnnoise.so

            rm $out/share/${pname}/lib/rtmidi.so
            ln -s ${rtmidi}/lib/librtmidi.so $out/share/${pname}/lib/rtmidi.so

            rm $out/share/${pname}/lib/libonnxruntime.so
            rm $out/share/${pname}/lib/libonnxruntime_providers_shared.so

            mkdir -p $out/bin
            cat > $out/bin/veadotube<< EOF
            #! ${lib.getExe bash}
            export WINEPREFIX=\$HOME/.local/share/${pname}
            export PATH=/run/wrappers/bin:${file}/bin:$PATH
            exec $out/share/${pname}/veadotube \$@
            EOF
            chmod +x $out/bin/veadotube

            cp -r ${desktopItem}/share/* $out/share/
        '';

    meta = {
        description = "A collection of tools for virtual puppetry made by olmewe and BELLA!.";
        homepage = "https://veado.tube";
        mainProgram = "veadotube";
        license = [
            {
                # restrictions on corporations apply for both use and redistribution
                shortName = "ISTSL";
                fullName = "\"i'm so tired\" software license 1.0";
                url = "https://olmewe.com/istsl/";
                free = false;
                redistributable = false;
                deprecated = false;
            }
        ];
    };
})
