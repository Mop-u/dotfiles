{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
{
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
        package = pkgs.paperServers.paper-1_21_4.override {
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
                url = "https://hangarcdn.papermc.io/plugins/Blue/BlueMap/versions/5.7/PAPER/bluemap-5.7-paper.jar";
                hash = "sha256-4T9Pf1FA/XlByNTmVIimj+7aCyX/BPy011gdT70mFAk=";
            };
            "plugins/DamageIndicator.jar" = pkgs.fetchurl {
                url = "https://github.com/MagicCheese1/Damage-Indicator/releases/download/v2.2.0/DamageIndicator.jar";
                hash = "sha256-gtOMFhkgN1tGhB3+42X084kEt5kMJRqXtj029pDlQAU=";
            };
            "plugins/EssentialsX.jar" = pkgs.fetchurl {
                url = "https://github.com/EssentialsX/Essentials/releases/download/2.21.0/EssentialsX-2.21.0.jar";
                hash = "sha256-VwQyKlSDa5hLEQ9+Igi67RiGwu/tREa0l+Z+US/skMU=";
            };
            "plugins/EssentialsXChat.jar" = pkgs.fetchurl {
                url = "https://github.com/EssentialsX/Essentials/releases/download/2.21.0/EssentialsXChat-2.21.0.jar";
                hash = "sha256-EJbW7PYlDLL6AVUMGCe+cdgNP0ZPbu7/aOl9LUGOQT4=";
            };
            "plugins/EssentialsXSpawn.jar" = pkgs.fetchurl {
                url = "https://github.com/EssentialsX/Essentials/releases/download/2.21.0/EssentialsXSpawn-2.21.0.jar";
                hash = "sha256-Wv98mEx8i9mnDj7ppc9ILY/iqwyf+1PiGl7ZL0Of2pA=";
            };
            "plugins/FastAsyncWorldEdit.jar" = pkgs.fetchurl {
                url = "https://github.com/IntellectualSites/FastAsyncWorldEdit/releases/download/2.13.0/FastAsyncWorldEdit-Paper-2.13.0.jar";
                hash = "sha256-6Vhnc+DV7LGzuFTO1ntHNxovIsbMczCu60Q+omN7bPI=";
            };
            "plugins/LuckPerms.jar" = pkgs.fetchurl {
                url = "https://download.luckperms.net/1574/bukkit/loader/LuckPerms-Bukkit-5.4.157.jar";
                hash = "sha256-IGR0UFP2jBgMVD11iMIPj88nIBNvoha7JJ3218HBFXU=";
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
            #"plugins/Slabs.jar" = pkgs.fetchurl {
            #    url = "https://mediafilez.forgecdn.net/files/2381/666/Slabs-2.2.0.jar";
            #    hash = "sha256-95oOuGumIRFcJio+VCXKi1TASVrdEEWf1HYJbVpXkmA=";
            #};
            "plugins/TabTPS.jar" = pkgs.fetchurl {
                url = "https://hangarcdn.papermc.io/plugins/jmp/TabTPS/versions/1.3.26/PAPER/tabtps-spigot-1.3.26.jar";
                hash = "sha256-Wd1CvvilPhqE1rATu1hu1X/FyP/GU7CujqL+iVSje7I=";
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
