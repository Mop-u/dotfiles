{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
{
    imports = [
        inputs.nix-minecraft.nixosModules.minecraft-servers
    ];
    nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];
    networking.firewall.allowedTCPPorts = [
        8100 # bluemap
    ];
    services.minecraft-servers = {
        enable = true;
        eula = true;
        dataDir = "/srv/minecraft"; # /srv/minecraft/paper
        runDir = "/run/minecraft"; # tmux -S /run/minecraft/paper.sock attach
    };
    services.minecraft-servers.servers.paper = {
        enable = true;
        openFirewall = true;
        autoStart = true;
        restart = "always";
        enableReload = false;
        serverProperties = {
            enable-rcon = false;
            enforce-whitelist = true;
            white-list = true;
            motd = "gameing";
            server-port = 25565;
            simulation-distance = 8;
            view-distance = 32;
            network-compression-threshold = 64;
            gamemode = "survival";
            difficulty = "easy";
        };
        package = pkgs.paperServers.paper-1_21_8.override {
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
            "plugins/bluemap.jar" = pkgs.fetchurl {
                url = "https://hangarcdn.papermc.io/plugins/Blue/BlueMap/versions/5.11/PAPER/bluemap-5.11-paper.jar";
                hash = "sha256-PUuWF2UB6KhHt/rOMgmHkOjraaYWgOEoUZfQo9eW1cA=";
            };
            "plugins/DamageIndicator.jar" = pkgs.fetchurl {
                url = "https://github.com/MagicCheese1/Damage-Indicator/releases/download/v2.2.3/DamageIndicator.jar";
                hash = "sha256-01aeWY1DgbbDE/RHj8DSL/TZcF/MP97FrYY7w4RrTy4=";
            };
            "plugins/EssentialsX.jar" = pkgs.fetchurl {
                url = "https://github.com/EssentialsX/Essentials/releases/download/2.21.2/EssentialsX-2.21.2.jar";
                hash = "sha256-C3WQJvAvPFR8MohvNmbbPB+Uz/c+FBrlZIMT/Q0L38Y=";
            };
            "plugins/EssentialsXChat.jar" = pkgs.fetchurl {
                url = "https://github.com/EssentialsX/Essentials/releases/download/2.21.2/EssentialsXChat-2.21.2.jar";
                hash = "sha256-Htc5MloULVLqyUg+r90yBLUeqnVWIV8D6QY739wACds=";
            };
            "plugins/EssentialsXSpawn.jar" = pkgs.fetchurl {
                url = "https://github.com/EssentialsX/Essentials/releases/download/2.21.2/EssentialsXSpawn-2.21.2.jar";
                hash = "sha256-CnobRGh7bZ2E+vQkNgsuBKKr9FDi2ZmPJ7K6RwZ0a4Y=";
            };
            "plugins/FastAsyncWorldEdit.jar" = pkgs.fetchurl {
                url = "https://ci.athion.net/job/FastAsyncWorldEdit/1167/artifact/artifacts/FastAsyncWorldEdit-Paper-2.13.2-SNAPSHOT-1167.jar";
                hash = "sha256-Q0Ex3pjIQ+ApVlidUQ4l7TfNMHdD1VFp7JdXjHLjf2M=";
            };
            "plugins/LuckPerms.jar" = pkgs.fetchurl {
                url = "https://download.luckperms.net/1596/bukkit/loader/LuckPerms-Bukkit-5.5.11.jar";
                hash = "sha256-oBi4uzcDx97rNs69Efeb8WOEtrUFbN9UI3/DzOmiAuI=";
            };
            "plugins/multiverse-core.jar" = pkgs.fetchurl {
                url = "https://hangarcdn.papermc.io/plugins/Multiverse/Multiverse-Core/versions/5.2.1/PAPER/multiverse-core-5.2.1.jar";
                hash = "sha256-KE3e/VRp2KOo1gUiouopMZ06g15umLKpBXoCFdj0v+o=";
            };
            "plugins/multiverse-inventories.jar" = pkgs.fetchurl {
                url = "https://hangarcdn.papermc.io/plugins/Multiverse/Multiverse-Inventories/versions/5.1.2/PAPER/multiverse-inventories-5.1.2.jar";
                hash = "sha256-NxPlOJ4w/s6sSNe5EQWbo8XoG0PAfgQeWdcGZVu+G54=";
            };
            "plugins/multiverse-netherportals.jar" = pkgs.fetchurl {
                url = "https://hangarcdn.papermc.io/plugins/Multiverse/Multiverse-NetherPortals/versions/5.0.3/PAPER/multiverse-netherportals-5.0.3.jar";
                hash = "sha256-H8dCstHnY9LX3tpzTi1s/j9fGS1yy7ePaTuenIQVcNU=";
            };
            #"plugins/Slabs.jar" = pkgs.fetchurl {
            #    url = "https://mediafilez.forgecdn.net/files/2381/666/Slabs-2.2.0.jar";
            #    hash = "sha256-95oOuGumIRFcJio+VCXKi1TASVrdEEWf1HYJbVpXkmA=";
            #};
            "plugins/TabTPS.jar" = pkgs.fetchurl {
                url = "https://hangarcdn.papermc.io/plugins/jmp/TabTPS/versions/1.3.28/PAPER/tabtps-spigot-1.3.28.jar";
                hash = "sha256-qJ0W3LE75i8eO0SoatxGv+YDoN2IldT02uvRS1shG+g=";
            };
            "plugins/Vault.jar" = pkgs.fetchurl {
                url = "https://github.com/MilkBowl/Vault/releases/download/1.7.3/Vault.jar";
                hash = "sha256-prXtl/Q6XPW7rwCnyM0jxa/JvQA/hJh1r4s25s930B0=";
            };
            #"plugins/ViaVersion.jar" = pkgs.fetchurl {
            #    url = "https://hangarcdn.papermc.io/plugins/ViaVersion/ViaVersion/versions/5.2.0/PAPER/ViaVersion-5.2.0.jar";
            #    hash = "sha256-wM6rCamKhMS0vGdMlgVrZDFzGlLGgu76+s2TVDEnlVs=";
            #};
            #"plugins/WorldEditSUI.jar" = pkgs.fetchurl {
            #    url = "https://github.com/kennytv/WorldEditSUI/releases/download/1.7.4/WorldEditSUI-1.7.4.jar";
            #    hash = "sha256-cAbPnllEx14bV8wZ3IjtF/wXmg4oNU/aQkqjKpWqw9g=";
            #};
        };
    };
}
