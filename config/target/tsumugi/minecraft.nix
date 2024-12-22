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
        symlinks = {
            "plugins/DamageIndicator.jar" = pkgs.fetchurl {
                url = "https://github.com/MagicCheese1/Damage-Indicator/releases/download/v2.1.4/DamageIndicator.jar";
                hash = "sha256-sOZPuxTAl5ykFdowZIxXZgFdiTEm6jQDIsxHaynOIsQ=";
            };
            "plugins/EssentialsX.jar" = pkgs.fetchurl {
                url = "https://ci.ender.zone/job/EssentialsX/lastSuccessfulBuild/artifact/jars/EssentialsX-2.21.0-dev+151-f2af952.jar";
                hash = "sha256-VqlnQB9WSi6bM5PMWiEIkAga1oji94n+oriyjorYy/0="; 
            };
            "plugins/EssentialsXChat.jar" = pkgs.fetchurl {
                url = "https://ci.ender.zone/job/EssentialsX/lastSuccessfulBuild/artifact/jars/EssentialsXChat-2.21.0-dev+151-f2af952.jar";
                hash = "sha256-0aDFEkOC3puic46PpyX/Ng5frG2yuJXhtKfdcbXFr4I=";
            };
            "plugins/EssentialsXSpawn.jar" = pkgs.fetchurl {
                url = "https://ci.ender.zone/job/EssentialsX/lastSuccessfulBuild/artifact/jars/EssentialsXSpawn-2.21.0-dev+151-f2af952.jar";
                hash = "sha256-R6HQE7eumo7EW3r4bqzr1eEEs6x4SRSBOQ9MtzVzSTg="; 
            };
            "plugins/FastAsyncWorldEdit.jar" = pkgs.fetchurl {
                url = "https://github.com/IntellectualSites/FastAsyncWorldEdit/releases/download/2.12.2/FastAsyncWorldEdit-Paper-2.12.2.jar";
                hash = "sha256-/6vjPK8c9ooI01vpnGzYvlji3rXNAx5pxwu3WX8ArT8="; 
            };
            "plugins/LuckPerms.jar" = pkgs.fetchurl {
                url = "https://download.luckperms.net/1561/bukkit/loader/LuckPerms-Bukkit-5.4.146.jar";
                hash = "sha256-RKxwhPoshigjWBNihucTkaOSZZhYcBlNvhmnWFaTH0U="; 
            };
            "plugins/multiverse-core.jar" = pkgs.fetchurl {
                url = "https://github.com/Multiverse/Multiverse-Core/releases/download/4.3.14/multiverse-core-4.3.14.jar";
                hash = "sha256-J2MOl8aGEvLM0a9ykFVSjiKIeSPM5vbOzDTkVYPlrhE="; 
            };
            "plugins/multiverse-inventories.jar" = pkgs.fetchurl {
                url = "https://github.com/Multiverse/Multiverse-Inventories/releases/download/4.2.7-pre/multiverse-inventories-4.2.7-pre.jar";
                hash = "sha256-fxwMD3nrm7LOEOkCEThhg1ozB30XauFf00KCYw3bS8E="; 
            };
            "plugins/multiverse-netherportals.jar" = pkgs.fetchurl {
                url = "https://hangarcdn.papermc.io/plugins/Multiverse/Multiverse-NetherPortals/versions/4.2.3/PAPER/multiverse-netherportals-4.2.3.jar";
                hash = "sha256-lyg5Vak62oL15wk4gDhII+IkZxl4uOZ2njwnuhWxusM=";
            };
            "plugins/Slabs.jar" = pkgs.fetchurl {
                url = "https://mediafilez.forgecdn.net/files/2381/666/Slabs-2.2.0.jar";
                hash = "sha256-95oOuGumIRFcJio+VCXKi1TASVrdEEWf1HYJbVpXkmA="; 
            };
            "plugins/TabTPS.jar" = pkgs.fetchurl {
                url = "https://hangarcdn.papermc.io/plugins/jmp/TabTPS/versions/1.3.25/PAPER/tabtps-spigot-1.3.25.jar";
                hash = "sha256-f+mc1bGwc5BKgWiog3ABEKSeVeOrFEr06OogM6oUBAA="; 
            };
            "plugins/Vault.jar" = pkgs.fetchurl {
                url = "https://github.com/MilkBowl/Vault/releases/download/1.7.3/Vault.jar";
                hash = "sha256-prXtl/Q6XPW7rwCnyM0jxa/JvQA/hJh1r4s25s930B0="; 
            };
            "plugins/ViaBackwards.jar" = pkgs.fetchurl {
                url = "https://github.com/ViaVersion/ViaBackwards/releases/download/5.1.1/ViaBackwards-5.1.1.jar";
                hash = "sha256-FN/kBvT9f/i4Em9dXCteSWvlpYLIy81HiyN/rJIeunU="; 
            };
            "plugins/ViaVersion.jar" = pkgs.fetchurl {
                url = "https://github.com/ViaVersion/ViaVersion/releases/download/5.1.1/ViaVersion-5.1.1.jar";
                hash = "sha256-4j8Vj42k2UhgcgcB93iSRCO0GPqdH4Ya7IlcKKDw6Tw="; 
            };
            "plugins/WorldEditSUI.jar" = pkgs.fetchurl {
                url = "https://github.com/kennytv/WorldEditSUI/releases/download/1.7.4/WorldEditSUI-1.7.4.jar";
                hash = "sha256-cAbPnllEx14bV8wZ3IjtF/wXmg4oNU/aQkqjKpWqw9g="; 
            };
        };
    };
}