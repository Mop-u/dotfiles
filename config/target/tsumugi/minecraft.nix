{ inputs, config, pkgs, lib, target, ... }:
{
    nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

    services.minecraft-servers = {
        enable = true;
        eula = true;
        dataDir = "/srv/minecraft"; # /srv/minecraft/servername
        runDir = "/run/minecraft"; # tmux -S /run/minecraft/servername.sock attach
    };
    services.minecraft-servers.servers.paper = {
        enable = true;
        openFirewall = true;
        autoStart = true;
        restart = "always";
        enableReload = false;
        serverProperties = {
            enable-rcon=false;
            enforce-whitelist=true;
            white-list=true;
            motd="gameing";
            server-port=25565;
            simulation-distance=16;
            view-distance=32;
            gamemode = "survival";
            difficulty = "easy";
        };
        package = pkgs.paperServers.paper-1_21_3.override{
            jre = pkgs.graalvm-ce;
        };
        jvmOpts = lib.concatStringsSep " " [
            "-Xmx18G"
            "-Xms18G"
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