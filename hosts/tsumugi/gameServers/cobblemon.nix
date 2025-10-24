{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
let
    # https://leixb.fly.dev/blog/modrinth-modpacks-nix
    # fetchzip doesn't let us fix the file permissions after extracting... (no read permissions :/)
    modpack = pkgs.stdenvNoCC.mkDerivation {
        name = "cobblemon-modpack";
        dontConfigure = true;
        src = pkgs.fetchurl {
            name = "cobblemon.zip";
            url = "https://cdn.modrinth.com/data/5FFgwNNP/versions/98odLiu9/Cobblemon%20Official%20%5BFabric%5D%201.6.1.4.mrpack";
            hash = "sha256-xABBCrPpCJL+YwO1pvX4lbYzxFwGkzvduXX08vhCpnU=";
        };
        nativeBuildInputs = [ pkgs.unzip ];
        postUnpack = ''
            chmod -R +r *
            find . -type d -exec chmod +x {} \;
        '';
        installPhase = ''
            ls -la ../
            mkdir $out
            cp -R ../ $out/
        '';
    };

    mkMod =
        name: mod:
        pkgs.runCommand name { } ''
            mkdir -p $out/mods
            cp ${mod} $out/mods
        '';

    extra_mods = [
        (mkMod "Cobblemon Unchained" (
            pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/wh0wnzrT/versions/loS5XVHf/unchained-fabric-1.6.1-1.5.2.jar";
                hash = "sha256-qVJUC+FVKLVprxJrdJwN520BY2M5zvbh+kdW2vXo+zo=";
            }
        ))
        (mkMod "Tim Core" (
            pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/lVP9aUaY/versions/NsLwACmT/timcore-fabric-1.6.1-1.15.3.jar";
                hash = "sha256-N56Z9vZGT97poLC1mql+v8Y9PtPOZ4tnG8I2F69R0/U=";
            }
        ))
        (mkMod "Cobblemon Counter" (
            pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/rj8uLYP4/versions/ReIkCnf8/counter-fabric-1.6.1-1.6.1.jar";
                hash = "sha256-mUHnMvsPkxlIembW8D2sUnTLq3F3M7SZ9hevbEJpmYg=";
            }
        ))
    ];

    cobblemonFiles =
        let
            modrinthIndex = builtins.fromJSON (builtins.readFile "${modpack}/modrinth.index.json");

            files = builtins.filter (
                file: !(file ? env) || file.env.server != "unsupported"
            ) modrinthIndex.files;

            downloads = builtins.map (
                file:
                pkgs.fetchurl {
                    urls = file.downloads;
                    inherit (file.hashes) sha512;
                }
            ) files;

            paths = builtins.map (builtins.getAttr "path") files;

            derivations = lib.zipListsWith (
                path: download:
                let
                    folderName = builtins.match "(.*)/(.*$)" path;
                    folder = builtins.head folderName;
                    name = builtins.head (builtins.tail folderName);
                in
                pkgs.runCommand name { } ''
                    mkdir -p "$out/${folder}"
                    cp ${download} "$out/${path}"
                ''
            ) paths downloads;
        in
        pkgs.symlinkJoin {
            inherit (modrinthIndex) name;
            paths = derivations ++ [ "${modpack}/overrides" ] ++ extra_mods;
        };
in
{
    services.minecraft-servers.servers.cobblemon = {
        enable = true;
        autoStart = true;
        openFirewall = true;
        package = pkgs.fabricServers.fabric-1_21_1;
        serverProperties = {
            enable-rcon = false;
            enforce-whitelist = true;
            white-list = true;
            server-port = 25566;
            network-compression-threshold = 64;
            difficulty = "normal";
        };
        symlinks = lib.genAttrs [
            "mods"
            "icon.png"
            "instance.png"
        ] (name: "${cobblemonFiles}/${name}");
        files =
            let
                confFiles = lib.filesystem.listFilesRecursive "${cobblemonFiles}/config";
            in
            builtins.listToAttrs (
                builtins.map (value: {
                    name = builtins.unsafeDiscardStringContext (lib.strings.removePrefix "${cobblemonFiles}/" value);
                    inherit value;
                }) confFiles
            );

        jvmOpts = lib.concatStringsSep " " [
            "-Xmx8G"
            "-Xms8G"
            "-XX:+AlwaysPreTouch"
            "-XX:+DisableExplicitGC"
            "-XX:+ParallelRefProcEnabled"
            "-XX:+PerfDisableSharedMem"
            "-XX:+UnlockExperimentalVMOptions"
            "-XX:+UseG1GC"
            "-XX:G1HeapRegionSize=16M"
            "-XX:G1HeapWastePercent=5"
            "-XX:G1MaxNewSizePercent=50"
            "-XX:G1MixedGCCountTarget=4"
            "-XX:G1MixedGCLiveThresholdPercent=90"
            "-XX:G1NewSizePercent=40"
            "-XX:G1RSetUpdatingPauseTimePercent=5"
            "-XX:G1ReservePercent=15"
            "-XX:InitiatingHeapOccupancyPercent=20"
            "-XX:MaxGCPauseMillis=200"
            "-XX:MaxTenuringThreshold=1"
            "-XX:SurvivorRatio=32"
            "-Dusing.aikars.flags=https://mcflags.emc.gs"
            "-Daikars.new.flags=true"
            "-Djava.net.preferIPv4Stack=true"
            "-Djava.net.preferIPv6Addresses=false"
        ];
    };
}
