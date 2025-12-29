{
    config,
    pkgs,
    inputs,
    lib,
    ...
}:
{
    imports = [
        ./hardware-configuration.nix
        ./networkMounts.nix
        ./virtualbox.nix
        ./quartus.nix
    ];
    networking.hostName = "kaoru";
    home-manager.users.hazama = {
        home.packages = [
            pkgs.wireshark
            pkgs.surfer
        ];
        programs.vscode = {
            profiles.default = {
                extensions = with pkgs.vscode-extensions; [
                    mbehr1.vsc-webshark
                    surfer-project.surfer
                    redhat.vscode-yaml
                    #sankooc.pcapviewer
                ];
                userSettings = {
                    "redhat.telemetry.enabled" = false;
                    "vsc-webshark.sharkdFullPath" = "${pkgs.wireshark}/bin/sharkd";
                    "workbench.editorAssociations" = {
                        #"*.pcap" = "proto.pcapng";
                        "*.pcap" = "vsc-webshark.pcap";

                    };
                };
            };
        };
        programs.ssh = {
            enable = true;
            includes = [ config.sops.secrets."hosts/gio".path ];
            enableDefaultConfig = false;
            matchBlocks."*" = {
                forwardAgent = false;
                addKeysToAgent = "no";
                compression = false;
                serverAliveInterval = 0;
                serverAliveCountMax = 3;
                hashKnownHosts = false;
                userKnownHostsFile = "~/.ssh/known_hosts";
                controlMaster = "no";
                controlPath = "~/.ssh/master-%r@%n:%p";
                controlPersist = "no";
            };
        };
    };
    nix.settings.keep-outputs = true;
    sidonia = {
        userName = "hazama";
        stateVer = "23.11";
        style.catppuccin = {
            flavor = "mocha";
            accent = "mauve";
        };
        ssh.pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINfNV3Z/LI/4ItskdADIC4JWqfW3Wae4TRK/Ahos5TgB hazama@kaoru";
        text.comicCode.enable = true;
        services.distributedBuilds.client.enable = true;
        isLaptop = true;
        geolocation.enable = true;
        graphics.enable = true;
        programs = {
            gtkwave.enable = true;
            surfer.enable = true;
        };
        desktop.monitors = [
            {
                name = "eDP-1";
                resolution = "2560x1600";
                refresh = 165.00400;
                scale = 1.333333;
                position = "6720x0";
                extraArgs = "bitdepth, 10";
            }
            {
                name = "desc:Lenovo Group Limited P40w-20 V9095052";
                resolution = "5120x2160";
                refresh = 74.97900;
                scale = 1.066667;
                position = "0x0";
                extraArgs = lib.concatStringsSep "," [
                    "bitdepth,10"
                    "cm,hdr"
                    "sdrbrightness,1.2"
                ];
            }
            {
                name = "desc:BNQ ZOWIE XL LCD JAG03521SL0";
                resolution = "1920x1080";
                refresh = 60.00;
                scale = 1.0; # 0.833333;
                position = "4800x400";
            }
        ];
    };
    sops = {
        defaultSopsFile = ../../secrets/secrets.yaml;
        defaultSopsFormat = "yaml";
        age.keyFile = "/home/${config.sidonia.userName}/.config/sops/age/keys.txt";
        secrets."hosts/gio" = {
            owner = config.sidonia.userName;
        };
    };
}
