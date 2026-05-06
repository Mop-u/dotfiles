{
    osConfig,
    config,
    pkgs,
    lib,
    ...
}:
let
    slang-server = pkgs.callPackage ./slangServer.nix { };
in
{
    home.packages = [
        pkgs.wireshark
        (pkgs.quartusPackages.pro.latestWithDevices [ "cyclone10gx" ])
        pkgs.fiano
        pkgs.uefitoolPackages.old-engine
        pkgs.coreboot-utils
        pkgs.wineWowPackages.full
        #slang-server
    ];

    xdg.autostart.entries = lib.mkIf osConfig.services.asusd.enable [
        "${osConfig.services.asusd.package}/share/applications/rog-control-center.desktop"
    ];

    programs = {
        surfer.enable = true;
        gtkwave.enable = true;
        vscode = {
            profiles.default = {
                extensions = with pkgs.vsxExtensionsFor config.programs.vscode.package; [
                    mbehr1.vsc-webshark
                    #surfer-project.surfer
                    lramseyer.vaporview
                    redhat.vscode-yaml
                    christian-kohler.path-intellisense
                    llvm-vs-code-extensions.vscode-clangd
                    b-lang-org.language-bh
                    #hudson-river-trading.vscode-slang
                    ms-vscode.hexeditor
                    #sankooc.pcapviewer
                ];
                userSettings = {
                    "redhat.telemetry.enabled" = false;
                    "vsc-webshark.sharkdFullPath" = "${pkgs.wireshark}/bin/sharkd";
                    #"slang.path" = "${lib.getExe slang-server}";
                    "workbench.editorAssociations" = {
                        #"*.pcap" = "proto.pcapng";
                        "*.pcap" = "vsc-webshark.pcap";
                    };
                };
            };
        };
        ssh = {
            enable = true;
            includes = [
                osConfig.sops.secrets."hosts/gio".path
            ];
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
}
